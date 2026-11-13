# EduFlow — First admin setup

Public registration always creates a student account. Do not add a public admin bootstrap route.

After registering the project owner's account and confirming its email, open the SQL Editor in the dedicated EduFlow Supabase project. Replace the email placeholder with the exact owner email and run once:

```sql
update public.profiles p
set role = 'admin', updated_at = now()
from auth.users u
where p.id = u.id
  and lower(u.email) = lower('OWNER_EMAIL_HERE');
```

Verify:

```sql
select u.email, p.role
from public.profiles p
join auth.users u on u.id = p.id
where lower(u.email) = lower('OWNER_EMAIL_HERE');
```

Only the project owner should perform this bootstrap. Afterwards, admins can approve instructor applications at /admin/instructors. Never grant roles from client-submitted metadata.
