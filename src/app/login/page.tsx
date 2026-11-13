import Link from "next/link";
import { signIn } from "@/app/auth/actions";

export default async function Login({ searchParams }: { searchParams: Promise<{ error?: string; message?: string }> }) {
  const params = await searchParams;
  return <main className="auth-shell"><Link className="brand auth-brand" href="/">eduflow<span>.</span></Link><section className="auth-card"><div className="section-kicker">SELAMAT DATANG KEMBALI</div><h1>Masuk ke ruang belajarmu.</h1><p className="muted">Lanjutkan progres yang sudah kamu mulai.</p>
    {params.error && <p className="alert">{params.error}</p>}{params.message && <p className="success">{params.message}</p>}
    <form action={signIn} className="form"><label>Email<input name="email" type="email" autoComplete="email" required placeholder="nama@email.com"/></label><label>Password<input name="password" type="password" autoComplete="current-password" required placeholder="Masukkan password"/></label><button className="button full" type="submit">Masuk ↗</button></form>
    <p className="auth-foot">Belum punya akun? <Link href="/register">Daftar sekarang</Link></p><Link className="back-link" href="/">← Kembali ke beranda</Link></section></main>;
}
