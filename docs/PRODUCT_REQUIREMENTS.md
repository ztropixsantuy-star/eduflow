# EduFlow — Product Requirements (MVP)

## Product goal
Provide a simple Indonesian-language learning workspace for students and instructors.

## Personas
- Student: joins classes, reads lessons, submits assignments, takes quizzes, checks grades.
- Instructor: creates courses, publishes lessons/assignments/quizzes, reviews submissions.
- Admin: manages accounts, roles, and platform operations.

## MVP scope
1. Authentication and profile.
2. Course creation and enrollment by invite code.
3. Lessons and learning resources.
4. Assignments and submissions.
5. Multiple-choice quizzes and attempts.
6. Grades and learning progress.
7. Admin role management.

## Out of scope
AI tutor and AI question generation, payments/subscriptions, multi-institution tenancy, live video classroom, and native mobile applications.

## Acceptance criteria
- A student cannot access another student's private submission.
- A student cannot access quiz answer keys.
- Only course instructors/admins can author course content.
- A student can only join a published course with a valid invite code.
- All public application tables have RLS enabled.
- Main flows work on desktop and mobile.
