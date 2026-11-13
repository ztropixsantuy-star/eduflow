import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export default async function Courses() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data } = await supabase.from("course_members").select("course_id,courses(id,title,description,subject)").eq("user_id", user.id);
  return <main className="simple-page"><Link href="/dashboard" className="back-link">← Dashboard</Link><div className="section-kicker">RUANG BELAJAR</div><h1>Kelas saya</h1><p className="muted">Daftar kelas yang terhubung dengan akunmu.</p>{data?.length ? <div className="feature-grid">{data.map((row: any) => <article className="feature-card" key={row.course_id}><div className="feature-icon lavender">▤</div><h3>{row.courses?.title}</h3><p>{row.courses?.description}</p></article>)}</div> : <div className="empty-state"><div>▤</div><strong>Kamu belum bergabung ke kelas</strong><p>Minta kode undangan kelas kepada pengajar. Fitur bergabung dengan kode akan diaktifkan pada iterasi berikutnya.</p></div>}</main>;
}
