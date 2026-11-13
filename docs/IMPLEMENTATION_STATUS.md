# EduFlow implementation checkpoint

## Sprint 1 implemented
- Public registration creates student accounts only.
- Student can submit an instructor access request.
- Admin can approve/reject instructor requests; approval changes the trusted profile role.
- Instructor/admin can create published classes.
- Students can join published classes using invite codes.
- Invite codes are not selectable through the general courses Data API; owners retrieve codes through an owner-checked RPC.
- Public RPC entry points run as invoker; privileged operations are isolated in the non-exposed private schema.
- Admin profile visibility uses a private helper to avoid recursive RLS.
- Dashboard navigation includes the instructor workspace.

## Database migrations applied to the dedicated EduFlow project
- 0002_instructor_approval_and_course_join
- 0003_protect_invite_codes_and_admin_profile_read
- 0004_fix_admin_profile_policy_recursion
- 0005_isolate_privileged_rpc_helpers

The initial schema migration (0001) was already present in the project before this sprint.

## Validation
- Verified the instructor request table and three public RPC entry points exist.
- Verified authenticated users cannot directly select the course invite_code column.
- Verified anonymous users cannot execute the join RPC.
- Supabase Security Advisor returned no findings after hardening.

## Not completed / requires QA
- Lesson authoring and private file storage.
- Course detail page and member management.
- Assignment creation, submissions and grading.
- Quiz authoring, secure grading endpoint and attempts.
- Admin account management, announcements, notifications and analytics.
- Automated tests, dependency install, lint and production build.

## One-time setup
Follow ADMIN_BOOTSTRAP.md to promote the project owner's account to admin after registering and confirming the account.

## Deferred by decision
AI tutor, AI question generation, AI recommendations, gamification, badges, leaderboard, billing and multi-institution support.
