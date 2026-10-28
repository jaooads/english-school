import { BookOpen, ClipboardList, GraduationCap, Home, LogOut, Plus, UserRound } from 'lucide-react'
import { NavLink, Outlet } from 'react-router-dom'
import { useAuth } from '../../contexts/AuthContext'

const primaryNavigation = [
  { to: '/', label: 'Início', icon: Home, end: true },
  { to: '/aulas', label: 'Aulas', icon: BookOpen },
  { to: '/exercicios', label: 'Exercícios', icon: ClipboardList },
  { to: '/perfil', label: 'Perfil', icon: UserRound },
]

export function AppLayout() {
  const { profile, signOut } = useAuth()
  const isTeacher = profile?.role === 'TEACHER'

  return (
    <div className="app-shell">
      <aside className="sidebar">
        <div className="sidebar__brand">
          <span className="sidebar__logo"><GraduationCap size={24} /></span>
          <div><strong>English</strong><span>School</span></div>
        </div>

        <nav className="sidebar__nav" aria-label="Navegação principal">
          {primaryNavigation.map(({ to, label, icon: Icon, end }) => (
            <NavLink key={to} to={to} end={end} className={({ isActive }) => `nav-link ${isActive ? 'nav-link--active' : ''}`}>
              <Icon size={20} /> <span>{label}</span>
            </NavLink>
          ))}
        </nav>

        {isTeacher && (
          <NavLink to="/aulas/nova" className="button button--primary sidebar__new-lesson">
            <Plus size={18} /> Nova aula
          </NavLink>
        )}

        <div className="sidebar__profile">
          <span className="avatar">{profile?.name.charAt(0).toUpperCase()}</span>
          <div><strong>{profile?.name}</strong><span>{isTeacher ? 'Professora' : 'Aluno'}</span></div>
          <button className="icon-button" onClick={() => void signOut()} aria-label="Sair" title="Sair">
            <LogOut size={18} />
          </button>
        </div>
      </aside>

      <header className="mobile-header">
        <div className="sidebar__brand">
          <span className="sidebar__logo"><GraduationCap size={21} /></span>
          <div><strong>English</strong><span> School</span></div>
        </div>
        {isTeacher && <NavLink to="/aulas/nova" className="icon-button icon-button--accent" aria-label="Nova aula"><Plus size={20} /></NavLink>}
      </header>

      <main className="app-main"><Outlet /></main>

      <nav className="bottom-nav" aria-label="Navegação principal">
        {primaryNavigation.map(({ to, label, icon: Icon, end }) => (
          <NavLink key={to} to={to} end={end} className={({ isActive }) => `bottom-nav__link ${isActive ? 'bottom-nav__link--active' : ''}`}>
            <Icon size={21} /><span>{label}</span>
          </NavLink>
        ))}
      </nav>
    </div>
  )
}
