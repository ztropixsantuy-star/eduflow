import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export default async function Quizzes() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  return <main className="simple-page"><Link href="/dashboard" className="back-link">← Dashboard</Link><div className="section-kicker">UJI PEMAHAMAN</div><h1>Kuis</h1><p className="muted">Kuis yang diterbitkan pengajar akan tersedia di sini.</p><div className="empty-state"><div>✎</div><strong>Belum ada kuis</strong><p>Ruang kuis siap digunakan setelah modul kuis diimplementasikan.</p></div></main>;
}
