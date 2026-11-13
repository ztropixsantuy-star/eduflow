-- Keep RPC entry points invoker-rights; isolate privileged work in non-exposed private schema.
create or replace function private.join_course_by_code_impl(p_code text)
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
revoke all on function private.join_course_by_code_impl(text) from public,anon;
grant execute on function private.join_course_by_code_impl(text) to authenticated;
create or replace function public.join_course_by_code(p_code text)
returns uuid language sql security invoker set search_path=''
as $$ select private.join_course_by_code_impl(p_code); $$;
revoke all on function public.join_course_by_code(text) from public,anon;
grant execute on function public.join_course_by_code(text) to authenticated;

create or replace function private.get_my_course_invite_code_impl(p_course_id uuid)
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
revoke all on function private.get_my_course_invite_code_impl(uuid) from public,anon;
grant execute on function private.get_my_course_invite_code_impl(uuid) to authenticated;
create or replace function public.get_my_course_invite_code(p_course_id uuid)
returns text language sql security invoker set search_path=''
as $$ select private.get_my_course_invite_code_impl(p_course_id); $$;
revoke all on function public.get_my_course_invite_code(uuid) from public,anon;
grant execute on function public.get_my_course_invite_code(uuid) to authenticated;

create or replace function private.admin_review_instructor_request_impl(p_request_id uuid,p_approve boolean)
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
revoke all on function private.admin_review_instructor_request_impl(uuid,boolean) from public,anon;
grant execute on function private.admin_review_instructor_request_impl(uuid,boolean) to authenticated;
create or replace function public.admin_review_instructor_request(p_request_id uuid,p_approve boolean)
returns void language sql security invoker set search_path=''
as $$ select private.admin_review_instructor_request_impl(p_request_id,p_approve); $$;
revoke all on function public.admin_review_instructor_request(uuid,boolean) from public,anon;
grant execute on function public.admin_review_instructor_request(uuid,boolean) to authenticated;
