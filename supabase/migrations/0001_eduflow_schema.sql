-- EduFlow MVP schema
-- Apply only to a NEW, dedicated Supabase project after reviewing this migration.
create extension if not exists pgcrypto;

create type public.app_role as enum ('student', 'instructor', 'admin');
create type public.course_status as enum ('draft', 'published', 'archived');
create type public.submission_status as enum ('submitted', 'graded', 'returned');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  avatar_url text,
  education_level text,
  institution text,
  role public.app_role not null default 'student',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.courses (
  id uuid primary key default gen_random_uuid(),
  instructor_id uuid not null references public.profiles(id) on delete restrict,
  title text not null,
  description text not null default '',
  subject text,
  invite_code text not null unique default upper(substr(encode(gen_random_bytes(8), 'hex'), 1, 8)),
  status public.course_status not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.course_members (
  course_id uuid not null references public.courses(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key (course_id, user_id)
);

create table public.lessons (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses(id) on delete cascade,
  title text not null,
  content text not null default '',
  position integer not null default 0,
  is_published boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.lesson_resources (
  id uuid primary key default gen_random_uuid(),
  lesson_id uuid not null references public.lessons(id) on delete cascade,
  title text not null,
  file_path text not null,
  resource_type text not null default 'document',
  created_at timestamptz not null default now()
);

create table public.assignments (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses(id) on delete cascade,
  title text not null,
  description text not null default '',
  due_at timestamptz,
  max_score numeric(7,2) not null default 100 check (max_score > 0),
  is_published boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.submissions (
  id uuid primary key default gen_random_uuid(),
  assignment_id uuid not null references public.assignments(id) on delete cascade,
  student_id uuid not null references public.profiles(id) on delete cascade,
  text_answer text,
  file_path text,
  status public.submission_status not null default 'submitted',
  score numeric(7,2),
  feedback text,
  submitted_at timestamptz not null default now(),
  graded_at timestamptz,
  unique (assignment_id, student_id),
  check (score is null or score >= 0)
);

create table public.quizzes (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses(id) on delete cascade,
  title text not null,
  description text not null default '',
  duration_minutes integer check (duration_minutes is null or duration_minutes > 0),
  is_published boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.quiz_questions (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid not null references public.quizzes(id) on delete cascade,
  question_text text not null,
  position integer not null default 0,
  points numeric(7,2) not null default 1 check (points > 0)
);

create table public.quiz_options (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.quiz_questions(id) on delete cascade,
  option_text text not null,
  position integer not null default 0
);

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
create table private.quiz_answer_keys (
  question_id uuid primary key references public.quiz_questions(id) on delete cascade,
  correct_option_id uuid not null references public.quiz_options(id) on delete cascade
);
revoke all on private.quiz_answer_keys from public, anon, authenticated;

create table public.quiz_attempts (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid not null references public.quizzes(id) on delete cascade,
  student_id uuid not null references public.profiles(id) on delete cascade,
  score numeric(7,2),
  started_at timestamptz not null default now(),
  submitted_at timestamptz
);

create table public.quiz_answers (
  id uuid primary key default gen_random_uuid(),
  attempt_id uuid not null references public.quiz_attempts(id) on delete cascade,
  question_id uuid not null references public.quiz_questions(id) on delete cascade,
  selected_option_id uuid references public.quiz_options(id) on delete set null,
  unique (attempt_id, question_id)
);

create table public.announcements (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete restrict,
  title text not null,
  content text not null,
  created_at timestamptz not null default now()
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  body text not null default '',
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create index courses_instructor_idx on public.courses(instructor_id);
create index course_members_user_idx on public.course_members(user_id);
create index lessons_course_idx on public.lessons(course_id);
create index assignments_course_idx on public.assignments(course_id);
create index submissions_student_idx on public.submissions(student_id);
create index quizzes_course_idx on public.quizzes(course_id);
create index notifications_user_idx on public.notifications(user_id);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name, role)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', ''), 'student')
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

create or replace function private.is_course_instructor(target_course uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select (select auth.uid()) is not null and (
    exists (
      select 1 from public.courses c
      where c.id = target_course and c.instructor_id = (select auth.uid())
    ) or exists (
      select 1 from public.profiles p
      where p.id = (select auth.uid()) and p.role = 'admin'
    )
  );
$$;

create or replace function private.is_course_member(target_course uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select (select auth.uid()) is not null and exists (
    select 1 from public.course_members cm
    where cm.course_id = target_course and cm.user_id = (select auth.uid())
  );
$$;

revoke all on function private.is_course_instructor(uuid) from public, anon;
revoke all on function private.is_course_member(uuid) from public, anon;
grant usage on schema private to authenticated;
grant execute on function private.is_course_instructor(uuid) to authenticated;
grant execute on function private.is_course_member(uuid) to authenticated;

alter table public.profiles enable row level security;
alter table public.courses enable row level security;
alter table public.course_members enable row level security;
alter table public.lessons enable row level security;
alter table public.lesson_resources enable row level security;
alter table public.assignments enable row level security;
alter table public.submissions enable row level security;
alter table public.quizzes enable row level security;
alter table public.quiz_questions enable row level security;
alter table public.quiz_options enable row level security;
alter table public.quiz_attempts enable row level security;
alter table public.quiz_answers enable row level security;
alter table public.announcements enable row level security;
alter table public.notifications enable row level security;

create policy "profile_select_own" on public.profiles for select to authenticated
using (id = (select auth.uid()));
create policy "profile_update_own" on public.profiles for update to authenticated
using (id = (select auth.uid())) with check (id = (select auth.uid()));

create policy "course_read" on public.courses for select to authenticated
using (status = 'published' or instructor_id = (select auth.uid()) or private.is_course_member(id)
  or exists (select 1 from public.profiles p where p.id = (select auth.uid()) and p.role = 'admin'));
create policy "course_instructor_insert" on public.courses for insert to authenticated
with check (instructor_id = (select auth.uid()) and exists (
  select 1 from public.profiles p where p.id = (select auth.uid()) and p.role in ('instructor','admin')
));
create policy "course_instructor_update" on public.courses for update to authenticated
using (instructor_id = (select auth.uid()) or exists (
  select 1 from public.profiles p where p.id = (select auth.uid()) and p.role = 'admin'
))
with check (instructor_id = (select auth.uid()) or exists (
  select 1 from public.profiles p where p.id = (select auth.uid()) and p.role = 'admin'
));

create policy "member_read_self_or_teacher" on public.course_members for select to authenticated
using (user_id = (select auth.uid()) or private.is_course_instructor(course_id));
create policy "member_remove_by_teacher" on public.course_members for delete to authenticated
using (private.is_course_instructor(course_id) or user_id = (select auth.uid()));

create policy "lesson_read_member" on public.lessons for select to authenticated
using (private.is_course_instructor(course_id) or (is_published and private.is_course_member(course_id)));
create policy "lesson_manage_teacher" on public.lessons for all to authenticated
using (private.is_course_instructor(course_id)) with check (private.is_course_instructor(course_id));

create policy "resource_read_member" on public.lesson_resources for select to authenticated
using (exists (select 1 from public.lessons l where l.id = lesson_id and
  (private.is_course_instructor(l.course_id) or (l.is_published and private.is_course_member(l.course_id))));
create policy "resource_manage_teacher" on public.lesson_resources for all to authenticated
using (exists (select 1 from public.lessons l where l.id = lesson_id and private.is_course_instructor(l.course_id)))
with check (exists (select 1 from public.lessons l where l.id = lesson_id and private.is_course_instructor(l.course_id)));

create policy "assignment_read_member" on public.assignments for select to authenticated
using (private.is_course_instructor(course_id) or (is_published and private.is_course_member(course_id)));
create policy "assignment_manage_teacher" on public.assignments for all to authenticated
using (private.is_course_instructor(course_id)) with check (private.is_course_instructor(course_id));

create policy "submission_read_student_or_teacher" on public.submissions for select to authenticated
using (student_id = (select auth.uid()) or exists (
  select 1 from public.assignments a where a.id = assignment_id and private.is_course_instructor(a.course_id)
));
create policy "submission_insert_self" on public.submissions for insert to authenticated
with check (student_id = (select auth.uid()) and exists (
  select 1 from public.assignments a where a.id = assignment_id and a.is_published and private.is_course_member(a.course_id)
));
create policy "submission_update_student_or_teacher" on public.submissions for update to authenticated
using (student_id = (select auth.uid()) or exists (
  select 1 from public.assignments a where a.id = assignment_id and private.is_course_instructor(a.course_id)
))
with check (student_id = (select auth.uid()) or exists (
  select 1 from public.assignments a where a.id = assignment_id and private.is_course_instructor(a.course_id)
));

create policy "quiz_read_member" on public.quizzes for select to authenticated
using (private.is_course_instructor(course_id) or (is_published and private.is_course_member(course_id)));
create policy "quiz_manage_teacher" on public.quizzes for all to authenticated
using (private.is_course_instructor(course_id)) with check (private.is_course_instructor(course_id));

create policy "question_read_member" on public.quiz_questions for select to authenticated
using (exists (select 1 from public.quizzes q where q.id = quiz_id and
  (private.is_course_instructor(q.course_id) or (q.is_published and private.is_course_member(q.course_id))));
create policy "question_manage_teacher" on public.quiz_questions for all to authenticated
using (exists (select 1 from public.quizzes q where q.id = quiz_id and private.is_course_instructor(q.course_id)))
with check (exists (select 1 from public.quizzes q where q.id = quiz_id and private.is_course_instructor(q.course_id)));

create policy "option_read_member" on public.quiz_options for select to authenticated
using (exists (select 1 from public.quiz_questions qq join public.quizzes q on q.id = qq.quiz_id
  where qq.id = question_id and (private.is_course_instructor(q.course_id) or (q.is_published and private.is_course_member(q.course_id))));
create policy "option_manage_teacher" on public.quiz_options for all to authenticated
using (exists (select 1 from public.quiz_questions qq join public.quizzes q on q.id = qq.quiz_id
  where qq.id = question_id and private.is_course_instructor(q.course_id)))
with check (exists (select 1 from public.quiz_questions qq join public.quizzes q on q.id = qq.quiz_id
  where qq.id = question_id and private.is_course_instructor(q.course_id)));

create policy "attempt_read_self_or_teacher" on public.quiz_attempts for select to authenticated
using (student_id = (select auth.uid()) or exists (
  select 1 from public.quizzes q where q.id = quiz_id and private.is_course_instructor(q.course_id)
));
create policy "attempt_insert_self" on public.quiz_attempts for insert to authenticated
with check (student_id = (select auth.uid()) and exists (
  select 1 from public.quizzes q where q.id = quiz_id and q.is_published and private.is_course_member(q.course_id)
));
create policy "attempt_update_self" on public.quiz_attempts for update to authenticated
using (student_id = (select auth.uid()) and submitted_at is null)
with check (student_id = (select auth.uid()));

create policy "answer_read_self_or_teacher" on public.quiz_answers for select to authenticated
using (exists (select 1 from public.quiz_attempts a where a.id = attempt_id and
  (a.student_id = (select auth.uid()) or exists (select 1 from public.quizzes q where q.id = a.quiz_id and private.is_course_instructor(q.course_id)))));
create policy "answer_insert_own_attempt" on public.quiz_answers for insert to authenticated
with check (exists (select 1 from public.quiz_attempts a where a.id = attempt_id and a.student_id = (select auth.uid()) and a.submitted_at is null));
create policy "answer_update_own_attempt" on public.quiz_answers for update to authenticated
using (exists (select 1 from public.quiz_attempts a where a.id = attempt_id and a.student_id = (select auth.uid()) and a.submitted_at is null))
with check (exists (select 1 from public.quiz_attempts a where a.id = attempt_id and a.student_id = (select auth.uid()) and a.submitted_at is null));

create policy "announcement_read_member" on public.announcements for select to authenticated
using (private.is_course_instructor(course_id) or private.is_course_member(course_id));
create policy "announcement_manage_teacher" on public.announcements for all to authenticated
using (private.is_course_instructor(course_id)) with check (private.is_course_instructor(course_id));

create policy "notification_read_own" on public.notifications for select to authenticated
using (user_id = (select auth.uid()));
create policy "notification_update_own" on public.notifications for update to authenticated
using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

revoke update on public.profiles from authenticated;
grant update (full_name, avatar_url, education_level, institution, updated_at) on public.profiles to authenticated;
grant select on public.profiles, public.courses, public.course_members, public.lessons, public.lesson_resources,
  public.assignments, public.submissions, public.quizzes, public.quiz_questions, public.quiz_options,
  public.quiz_attempts, public.quiz_answers, public.announcements, public.notifications to authenticated;
grant insert, update, delete on public.courses, public.lessons, public.lesson_resources, public.assignments,
  public.quizzes, public.quiz_questions, public.quiz_options, public.announcements to authenticated;
grant delete on public.course_members to authenticated;
grant insert (assignment_id, student_id, text_answer, file_path) on public.submissions to authenticated;
grant insert (quiz_id, student_id) on public.quiz_attempts to authenticated;
grant insert (attempt_id, question_id, selected_option_id), update (selected_option_id)
  on public.quiz_answers to authenticated;
grant update (read_at) on public.notifications to authenticated;

-- Storage bucket policies and secure quiz grading endpoint are follow-up tasks.
-- Never expose private.quiz_answer_keys to authenticated users.
