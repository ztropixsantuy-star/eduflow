# EduFlow implementation checkpoint

## Sprint 1 completed
- Public sign-up creates student accounts only.
- Student can submit an instructor access request.
- Admin can approve/reject instructor requests; approval changes the trusted profile role.
- Instructor/admin can create published classes.
- Students can join published classes using invite codes.
- Invite codes are not selectable through the general courses Data API; owners retrieve their code through an owner-checked RPC.
- Admin-only profile visibility uses a private helper to avoid recursive RLS.
- Dashboard navigation includes the instructor workspace.

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
