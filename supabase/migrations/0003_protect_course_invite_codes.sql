-- Protect invite codes from regular authenticated course browsing.
revoke select on table public.courses from authenticated;
grant select (id,instructor_id,title,description,subject,status,created_at,updated_at) on public.courses to authenticated;

create or replace function public.get_my_course_invite_code(p_course_id uuid)
returns text language plpgsql security definer set search_path=''
as $$
declare v_code text;
begin
 if (select auth.uid()) is null then raise exception 'Silakan masuk terlebih dahulu.' using errcode='28000'; end if;
 select c.invite_code into v_code from public.courses c
 where c.id=p_course_id and (c.instructor_id=(select auth.uid()) or exists(select 1 from public.profiles p where p.id=(select auth.uid()) and p.role='admin'));
 if v_code is null then raise exception 'Kelas tidak ditemukan atau akses ditolak.' using errcode='42501'; end if;
 return v_code;
end;
$$;
revoke all on function public.get_my_course_invite_code(uuid) from public,anon;
grant execute on function public.get_my_course_invite_code(uuid) to authenticated;
