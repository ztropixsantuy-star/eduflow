import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export default async function Assignments() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  return <main className="simple-page"><Link href="/dashboard" className="back-link">← Dashboard</Link><div className="section-kicker">AKTIVITAS BELAJAR</div><h1>Tugas</h1><p className="muted">Tugas dari kelas yang kamu ikuti akan ditampilkan di sini.</p><div className="empty-state"><div>◷</div><strong>Belum ada tugas</strong><p>Setelah pengajar menerbitkan tugas untuk kelasmu, tugas akan muncul di halaman ini.</p></div></main>;
}
