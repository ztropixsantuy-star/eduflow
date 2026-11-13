import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export default async function Settings() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  return <main className="simple-page"><Link href="/dashboard" className="back-link">← Dashboard</Link><div className="section-kicker">AKUN</div><h1>Pengaturan</h1><p className="muted">Informasi akun yang sedang digunakan.</p><div className="panel settings-panel"><span className="section-kicker">EMAIL</span><strong>{user.email}</strong><span className="section-kicker">USER ID</span><code>{user.id}</code></div></main>;
}
