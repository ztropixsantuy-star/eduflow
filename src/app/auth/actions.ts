"use server";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export async function signIn(formData: FormData) {
  const email=String(formData.get("email")||"").trim(), password=String(formData.get("password")||"");
  if(!email||!password) redirect("/login?error=Lengkapi%20email%20dan%20password");
  const supabase=await createClient();
  const {error}=await supabase.auth.signInWithPassword({email,password});
  if(error) redirect(`/login?error=${encodeURIComponent(error.message)}`);
  redirect("/dashboard");
}
export async function signUp(formData: FormData) {
  const fullName=String(formData.get("fullName")||"").trim(),email=String(formData.get("email")||"").trim(),password=String(formData.get("password")||"");
  if(!fullName||!email||password.length<8) redirect("/register?error=Nama%20dan%20email%20wajib%20diisi%3B%20password%20minimal%208%20karakter");
  const supabase=await createClient();
  const {data,error}=await supabase.auth.signUp({email,password,options:{data:{full_name:fullName}}});
  if(error) redirect(`/register?error=${encodeURIComponent(error.message)}`);
  if(data.session) redirect("/dashboard?welcome=1");
  redirect("/login?message=Periksa%20email%20untuk%20konfirmasi%20akun");
}
export async function signOut(){const supabase=await createClient();await supabase.auth.signOut();redirect("/");}

export async function requestInstructorRole(formData:FormData){
 const message=String(formData.get("message")||"").trim().slice(0,500);
 const supabase=await createClient();const {data:{user}}=await supabase.auth.getUser();if(!user)redirect("/login");
 const {data:profile}=await supabase.from("profiles").select("role").eq("id",user.id).single();
 if(profile?.role!=="student")redirect("/teach?error=Akun%20tidak%20memenuhi%20syarat%20pengajuan");
 const {error}=await supabase.from("instructor_requests").insert({user_id:user.id,message});
 if(error)redirect(`/teach?error=${encodeURIComponent(error.code==="23505"?"Permohonan%20kamu%20masih%20menunggu%20persetujuan":error.message)}`);
 redirect("/teach?message=Permohonan%20pengajar%20berhasil%20dikirim");
}
export async function createCourse(formData:FormData){
 const title=String(formData.get("title")||"").trim(),description=String(formData.get("description")||"").trim(),subject=String(formData.get("subject")||"").trim();
 if(title.length<3||title.length>100)redirect("/teach?error=Judul%20kelas%20harus%203-100%20karakter");
 const supabase=await createClient();const {data:{user}}=await supabase.auth.getUser();if(!user)redirect("/login");
 const {data:profile}=await supabase.from("profiles").select("role").eq("id",user.id).single();
 if(!profile||!["instructor","admin"].includes(profile.role))redirect("/teach?error=Akun%20belum%20memiliki%20akses%20pengajar");
 const {error}=await supabase.from("courses").insert({instructor_id:user.id,title,description,subject:subject||null,status:"published"});
 if(error)redirect(`/teach?error=${encodeURIComponent(error.message)}`);
 redirect("/teach?message=Kelas%20berhasil%20dibuat");
}
export async function joinCourse(formData:FormData){
 const code=String(formData.get("inviteCode")||"").trim();const supabase=await createClient();
 const {data:{user}}=await supabase.auth.getUser();if(!user)redirect("/login");
 const {error}=await supabase.rpc("join_course_by_code",{p_code:code});
 if(error)redirect(`/courses?error=${encodeURIComponent(error.message)}`);
 redirect("/courses?message=Berhasil%20bergabung%20ke%20kelas");
}
export async function reviewInstructorRequest(formData:FormData){
 const requestId=String(formData.get("requestId")||""),approve=String(formData.get("approve")||"")==="true";
 const supabase=await createClient();const {data:{user}}=await supabase.auth.getUser();if(!user)redirect("/login");
 const {data:profile}=await supabase.from("profiles").select("role").eq("id",user.id).single();if(profile?.role!=="admin")redirect("/dashboard");
 const {error}=await supabase.rpc("admin_review_instructor_request",{p_request_id:requestId,p_approve:approve});
 if(error)redirect(`/admin/instructors?error=${encodeURIComponent(error.message)}`);
 redirect("/admin/instructors?message=Permohonan%20berhasil%20ditinjau");
}
