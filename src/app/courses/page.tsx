import Link from "next/link";
import {redirect} from "next/navigation";
import {createClient} from "@/lib/supabase/server";
import {joinCourse} from "@/app/auth/actions";
export default async function Courses({searchParams}:{searchParams:Promise<{error?:string;message?:string}>}){
 const params=await searchParams,supabase=await createClient();const {data:{user}}=await supabase.auth.getUser();if(!user)redirect("/login");
 const [{data:memberships},{data:owned}]=await Promise.all([
  supabase.from("course_members").select("course_id,joined_at,courses(id,title,description,subject,instructor_id)").eq("user_id",user.id),
  supabase.from("courses").select("id,title,description,subject,status").eq("instructor_id",user.id).order("created_at",{ascending:false})
 ]);
 return <main className="simple-page"><Link href="/dashboard" className="back-link">← Dashboard</Link><div className="section-kicker">RUANG BELAJAR</div><h1>Kelas saya</h1><p className="muted">Gabung kelas dengan kode undangan atau buka kelas yang kamu kelola.</p>{params.error&&<p className="alert">{params.error}</p>}{params.message&&<p className="success">{params.message}</p>}
 <section className="panel form-panel"><div className="section-kicker">KODE UNDANGAN</div><h3>Gabung ke kelas</h3><form action={joinCourse} className="join-form"><input name="inviteCode" required minLength={4} maxLength={20} placeholder="Masukkan kode kelas"/><button className="button" type="submit">Gabung ↗</button></form></section>
 <section className="section-panel"><div className="section-kicker">KELAS YANG DIIKUTI</div><div className="feature-grid">{memberships?.length?memberships.map((row:any)=><article className="feature-card" key={row.course_id}><div className="feature-icon lavender">▤</div><h3>{row.courses?.title||"Kelas"}</h3><p>{row.courses?.subject||"Umum"} · {row.courses?.description||"Ruang belajar EduFlow"}</p></article>):<div className="empty-state"><div>▤</div><strong>Belum bergabung ke kelas</strong><p>Masukkan kode undangan dari pengajar untuk mulai belajar.</p></div>}</div></section>
 {owned?.length?<section className="section-panel"><div className="panel-head"><div><div className="section-kicker">KELAS YANG KAMU KELOLA</div><h3>{owned.length} kelas</h3></div><Link href="/teach">Kelola →</Link></div><div className="feature-grid">{owned.map(course=><article className="feature-card" key={course.id}><div className="feature-icon mint">✎</div><h3>{course.title}</h3><p>{course.subject||"Umum"} · {course.status}</p><small>Status: <strong>{course.status}</strong></small></article>)}</div></section>:null}
 <p><Link href="/teach" className="text-link">Buka ruang pengajar →</Link></p></main>;
}