# EduFlow — Education SaaS MVP

EduFlow is an Indonesian-language learning platform starter for students, university learners, and instructors.

## Included
- Next.js App Router + TypeScript
- Responsive Indonesian landing page
- Supabase SSR helpers and session middleware
- Authentication server actions
- Student dashboard and route shells for courses, assignments, quizzes, and settings
- PostgreSQL schema with Row Level Security (RLS)
- Private schema for quiz answer keys

## Setup
Requirements: Node.js 20.9+, Git, and a **dedicated Supabase project**.

1. Run `npm install`.
2. Copy `.env.example` to `.env.local` and fill in the Supabase URL and publishable key.
3. Review and apply `supabase/migrations/0001_eduflow_schema.sql` only to the dedicated EduFlow project.
4. Run `npm run dev` and open http://localhost:3000.

Public registration creates student accounts. Instructor/admin roles must be assigned through a trusted administrative process; never trust client-submitted roles or user metadata.

## Security
- RLS is enabled on public application tables.
- Quiz answer keys are kept in the non-exposed `private` schema.
- Secure server-side quiz grading and Storage policies are not yet implemented.
- Test policies using separate student, instructor, and admin accounts before production.
- Never expose service-role or secret keys in browser code.

## Not yet implemented
Instructor/admin UI, course invitation flows, lesson authoring, private uploads, assignment grading, secure quiz grading, end-to-end tests, and deployment. AI tutor and billing are intentionally out of MVP scope.

See `docs/PRODUCT_REQUIREMENTS.md` and `docs/IMPLEMENTATION_STATUS.md`.
