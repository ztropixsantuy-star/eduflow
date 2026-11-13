-- EduFlow sprint 1: instructor approval and secure course enrollment
create table if not exists public.instructor_requests (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(id) on delete cascade,
 message text not null default '',
 status text not null default 'pending' check (status in ('pending','approved','rejected')),
 reviewed_by uuid references public.profiles(id) on delete set null,
 reviewed_at timestamptz,
 created_at timestamptz not null default now()
);
create unique index if not exists instructor_requests_one_pending_per_user on public.instructor_requests(user_id) where status='pending';
create index if not exists instructor_requests_status_created_idx on public.instructor_requests(status,created_at desc);
alter table public.instructor_requests enable row level security;
create policy "instructor_request_read_own_or_admin" on public.instructor_requests for select to authenticated
using (user_id=(select auth.uid()) or exists(select 1 from public.profiles p where p.id=(select auth.uid()) and p.role='admin'));
create policy "instructor_request_insert_own_student" on public.instructor_requests for insert to authenticated
with check (user_id=(select auth.uid()) and exists(select 1 from public.profiles p where p.id=(select auth.uid()) and p.role='student'));
grant select,insert on public.instructor_requests to authenticated;

create or replace function public.join_course_by_code(p_code text)
returns uuid language plpgsql security definer set search_path=''
as $$
declare v_user_id uuid := (select auth.uid()); v_course_id uuid;
begin
 if v_user_id is null then raise exception 'Silakan masuk terlebih dahulu.' using errcode='28000'; end if;
 if p_code is null or length(trim(p_code))<4 or length(trim(p_code))>20 then raise exception 'Kode kelas tidak valid.' using errcode='22023'; end if;
 select c.id into v_course_id from public.courses c where upper(c.invite_code)=upper(trim(p_code)) and c.status='published' limit 1;
 if v_course_id is null then raise exception 'Kode kelas tidak ditemukan atau kelas belum dipublikasikan.' using errcode='P0002'; end if;
 insert into public.course_members(course_id,user_id) values(v_course_id,v_user_id) on conflict(course_id,user_id) do nothing;
 return v_course_id;
end;
$$;
revoke all on function public.join_course_by_code(text) from public,anon;
grant execute on function public.join_course_by_code(text) to authenticated;

create or replace function public.admin_review_instructor_request(p_request_id uuid,p_approve boolean)
returns void language plpgsql security definer set search_path=''
as $$
declare v_admin_id uuid := (select auth.uid()); v_user_id uuid;
begin
 if v_admin_id is null or not exists(select 1 from public.profiles p where p.id=v_admin_id and p.role='admin') then
  raise exception 'Hanya admin yang dapat meninjau permohonan.' using errcode='42501';
 end if;
 update public.instructor_requests set status=case when p_approve then 'approved' else 'rejected' end,
 reviewed_by=v_admin_id,reviewed_at=now() where id=p_request_id and status='pending' returning user_id into v_user_id;
 if v_user_id is null then raise exception 'Permohonan tidak ditemukan atau sudah ditinjau.' using errcode='P0002'; end if;
 if p_approve then update public.profiles set role='instructor',updated_at=now() where id=v_user_id and role='student'; end if;
end;
$$;
revoke all on function public.admin_review_instructor_request(uuid,boolean) from public,anon;
grant execute on function public.admin_review_instructor_request(uuid,boolean) to authenticated;

create policy "course_delete_by_owner_or_admin" on public.courses for delete to authenticated
using(instructor_id=(select auth.uid()) or exists(select 1 from public.profiles p where p.id=(select auth.uid()) and p.role='admin'));
