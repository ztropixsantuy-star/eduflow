-- Avoid recursive RLS evaluation when admins need to review applicant profiles.
drop policy if exists "profile_admin_read_all" on public.profiles;
create or replace function private.is_admin_user()
returns boolean language sql stable security definer set search_path=''
as $$
 select (select auth.uid()) is not null and exists(select 1 from public.profiles p where p.id=(select auth.uid()) and p.role='admin');
$$;
revoke all on function private.is_admin_user() from public,anon;
grant usage on schema private to authenticated;
grant execute on function private.is_admin_user() to authenticated;
create policy "profile_admin_read_all" on public.profiles for select to authenticated
using ((select private.is_admin_user()));
