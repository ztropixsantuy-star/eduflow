import Link from "next/link";
import { signUp } from "@/app/auth/actions";

export default async function Register({ searchParams }: { searchParams: Promise<{ error?: string }> }) {
  const params = await searchParams;
  return <main className="auth-shell"><Link className="brand auth-brand" href="/">eduflow<span>.</span></Link><section className="auth-card"><div className="section-kicker">MULAI PERJALANANMU</div><h1>Buat akun EduFlow.</h1><p className="muted">Bangun kebiasaan belajar yang lebih terarah.</p>
    {params.error && <p className="alert">{params.error}</p>}
    <form action={signUp} className="form"><label>Nama lengkap<input name="fullName" autoComplete="name" required placeholder="Nama kamu"/></label><label>Email<input name="email" type="email" autoComplete="email" required placeholder="nama@email.com"/></label><label>Daftar sebagai<select name="role" defaultValue="student"><option value="student">Pelajar / Mahasiswa</option><option value="instructor">Pengajar (perlu persetujuan admin)</option></select></label><label>Password<input name="password" type="password" minLength={8} autoComplete="new-password" required placeholder="Minimal 8 karakter"/></label><button className="button full" type="submit">Buat akun ↗</button></form>
    <p className="auth-foot">Sudah punya akun? <Link href="/login">Masuk</Link></p><Link className="back-link" href="/">← Kembali ke beranda</Link></section></main>;
}
