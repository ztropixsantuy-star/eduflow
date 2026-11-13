import Link from "next/link";
import { createClient } from "@/lib/supabase/server";

export default async function Home() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  return (
    <main>
      <nav className="topbar container">
        <Link className="brand" href="/">eduflow<span>.</span></Link>
        <div className="navlinks">
          <a href="#fitur">Fitur</a><a href="#cara-kerja">Cara kerja</a>
          {user ? <Link className="button button-small" href="/dashboard">Dashboard</Link> : <Link className="button button-small" href="/login">Masuk</Link>}
        </div>
      </nav>
      <section className="hero container">
        <div className="hero-copy">
          <div className="eyebrow"><span className="dot" /> RUANG BELAJAR DIGITAL</div>
          <h1>Belajar lebih terarah.<br/><em>Bertumbuh</em> setiap hari.</h1>
          <p className="lead">Satu ruang untuk mengelola kelas, memahami materi, menyelesaikan tugas, dan melihat perkembangan belajarmu.</p>
          <div className="hero-actions">
            <Link className="button" href={user ? "/dashboard" : "/register"}>Mulai belajar <span>↗</span></Link>
            <a className="text-link" href="#fitur">Jelajahi fitur ↓</a>
          </div>
          <div className="hero-note"><span className="avatar-stack"><b>A</b><b>B</b><b>C</b></span><span>Dirancang untuk pelajar dan mahasiswa</span></div>
        </div>
        <div className="hero-visual">
          <div className="visual-glow" />
          <div className="study-card">
            <div className="card-top"><span>RINGKASAN BELAJAR</span><span className="live-pill">● LIVE SPACE</span></div>
            <div className="greeting">Selamat datang kembali! <span>✦</span></div>
            <div className="visual-title">Perjalanan belajarmu<br/>dimulai dari sini.</div>
            <div className="progress-label"><span>Progres mingguan</span><strong>72%</strong></div>
            <div className="progress-track"><i /></div>
            <div className="mini-grid">
              <div><small>KELAS AKTIF</small><strong>04</strong><span>Terus konsisten</span></div>
              <div><small>TUGAS SELESAI</small><strong>12</strong><span>Good progress!</span></div>
            </div>
            <div className="next-class"><div className="class-icon">✎</div><div><small>SELANJUTNYA</small><strong>Matematika Dasar</strong></div><span className="arrow">↗</span></div>
          </div>
          <div className="floating-note"><span>✦</span> Keep learning, keep growing.</div>
        </div>
      </section>
      <section id="fitur" className="features container">
        <div className="section-kicker">SEMUA YANG KAMU BUTUHKAN</div>
        <h2>Belajar tanpa kehilangan arah.</h2>
        <div className="feature-grid">
          <article className="feature-card"><div className="feature-icon lavender">▤</div><h3>Kelas terorganisir</h3><p>Gabungkan materi dan aktivitas belajar dalam satu ruang kelas digital.</p></article>
          <article className="feature-card"><div className="feature-icon mint">✓</div><h3>Tugas dan kuis</h3><p>Kerjakan tugas, ikuti kuis, dan pantau hasil belajarmu.</p></article>
          <article className="feature-card"><div className="feature-icon peach">↗</div><h3>Progres belajar</h3><p>Lihat aktivitas dan perkembangan belajarmu secara bertahap.</p></article>
        </div>
      </section>
      <section id="cara-kerja" className="bottom-cta container"><div><div className="section-kicker">MULAI DARI LANGKAH KECIL</div><h2>Siap membuat proses belajar lebih baik?</h2></div><Link className="button" href={user ? "/dashboard" : "/register"}>Buat akun gratis ↗</Link></section>
      <footer className="footer container"><Link className="brand" href="/">eduflow<span>.</span></Link><span>Belajar, bertumbuh, dan melangkah lebih jauh.</span><span>© 2026 EduFlow</span></footer>
    </main>
  );
}
