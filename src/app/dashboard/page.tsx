import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { signOut } from "@/app/auth/actions";

export default async function Dashboard() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const [{ data: profile }, { data: memberships }] = await Promise.all([
    supabase.from("profiles").select("full_name, role, education_level").eq("id", user.id).maybeSingle(),
    supabase.from("course_members").select("course_id, courses(id,title,description)").eq("user_id", user.id),
  ]);

  const name = profile?.full_name || user.email?.split("@")[0] || "Teman belajar";
  const courses = memberships || [];
  return <main className="app-shell"><aside className="sidebar"><Link className="brand" href="/">eduflow<span>.</span></Link><div className="side-label">MENU UTAMA</div><nav className="side-nav"><Link className="active" href="/dashboard">▦　Overview</Link><Link href="/courses">▤　Kelas saya</Link><Link href="/assignments">◷　Tugas</Link><Link href="/quizzes">✎　Kuis</Link><Link href="/settings">⚙　Pengaturan</Link></nav><div className="sidebar-bottom"><div className="user-chip"><div className="user-avatar">{name.slice(0,1).toUpperCase()}</div><div><strong>{name}</strong><small>{profile?.role || "student"}</small></div></div><form action={signOut}><button className="logout" type="submit">Keluar ↗</button></form></div></aside>
    <section className="workspace"><header className="dash-header"><div><div className="section-kicker">DASHBOARD PELAJAR</div><h1>Halo, {name.split(" ")[0]} <span>✦</span></h1><p className="muted">Siap melanjutkan perjalanan belajarmu hari ini?</p></div><div className="date-chip">EDUFLOW / LEARNING SPACE</div></header>
      <div className="welcome-panel"><div><div className="section-kicker">SATU LANGKAH LEBIH MAJU</div><h2>Belajar sedikit demi sedikit,<br/>hasil besar akan mengikuti.</h2><p>Atur kelas dan selesaikan aktivitas belajarmu dari satu tempat.</p><Link className="button button-light" href="/courses">Lihat kelas ↗</Link></div><div className="welcome-mark">✳</div></div>
      <div className="stat-grid"><article className="stat-card"><span>KELAS SAYA</span><strong>{courses.length}</strong><small>Kelas yang diikuti</small></article><article className="stat-card"><span>TUGAS AKTIF</span><strong>—</strong><small>Segera tersedia</small></article><article className="stat-card"><span>PROGRES BELAJAR</span><strong>—</strong><small>Data akan dihitung</small></article></div>
      <div className="content-grid"><section className="panel"><div className="panel-head"><div><div className="section-kicker">RUANG BELAJAR</div><h3>Kelas yang kamu ikuti</h3></div><Link href="/courses">Lihat semua →</Link></div>{courses.length ? <div className="course-list">{courses.map((item: any) => <article className="course-row" key={item.course_id}><div className="course-symbol">▤</div><div><strong>{item.courses?.title || "Kelas"}</strong><small>{item.courses?.description || "Ruang belajar EduFlow"}</small></div><span>↗</span></article>)}</div> : <div className="empty-state"><div>▤</div><strong>Belum ada kelas</strong><p>Gabung kelas menggunakan kode undangan dari pengajar.</p><Link className="button button-small" href="/courses">Jelajahi kelas</Link></div>}</section>
      <section className="panel"><div className="panel-head"><div><div className="section-kicker">AKTIVITAS</div><h3>Agenda tugas</h3></div></div><div className="empty-state compact"><div>◷</div><strong>Belum ada agenda</strong><p>Tugas dari kelasmu akan muncul di sini.</p></div></section></div>
    </section></main>;
}
