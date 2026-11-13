"use server";

import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export async function signIn(formData: FormData) {
  const email = String(formData.get("email") || "").trim();
  const password = String(formData.get("password") || "");
  if (!email || !password) redirect("/login?error=Lengkapi%20email%20dan%20password");

  const supabase = await createClient();
  const { error } = await supabase.auth.signInWithPassword({ email, password });
  if (error) redirect(`/login?error=${encodeURIComponent(error.message)}`);
  redirect("/dashboard");
}

export async function signUp(formData: FormData) {
  const fullName = String(formData.get("fullName") || "").trim();
  const email = String(formData.get("email") || "").trim();
  const password = String(formData.get("password") || "");
  const role = String(formData.get("role") || "student");

  if (!fullName || !email || password.length < 8) {
    redirect("/register?error=Nama%20dan%20email%20wajib%20diisi%3B%20password%20minimal%208%20karakter");
  }
  // Public sign-up can only create student accounts. Instructor/admin privileges
  // must be assigned by a trusted administrator, never by a submitted form field.
  const supabase = await createClient();
  const { data, error } = await supabase.auth.signUp({
    email, password,
    options: { data: { full_name: fullName, requested_role: role === "instructor" ? "instructor" : "student" } },
  });
  if (error) redirect(`/register?error=${encodeURIComponent(error.message)}`);
  if (data.session) redirect("/dashboard?welcome=1");
  redirect("/login?message=Periksa%20email%20untuk%20konfirmasi%20akun");
}

export async function signOut() {
  const supabase = await createClient();
  await supabase.auth.signOut();
  redirect("/");
}
