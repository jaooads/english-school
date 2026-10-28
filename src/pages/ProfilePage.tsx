import { LogOut, ShieldCheck, UserRound } from 'lucide-react'
import { PageHeader } from '../components/PageHeader'
import { useAuth } from '../contexts/AuthContext'

export function ProfilePage() {
  const { profile, session, signOut } = useAuth()

  return (
    <div className="page page--narrow">
      <PageHeader title="Perfil" description="Seu acesso ao caderno English School." />
      <section className="profile-card">
        <span className="profile-card__avatar"><UserRound size={34} /></span>
        <div className="profile-card__identity">
          <h2>{profile?.name}</h2>
          <span className={`role-badge ${profile?.role === 'TEACHER' ? 'role-badge--teacher' : ''}`}>
            <ShieldCheck size={15} /> {profile?.role === 'TEACHER' ? 'Professora' : 'Aluno'}
          </span>
        </div>
        <dl>
          <div><dt>E-mail</dt><dd>{session?.user.email}</dd></div>
          <div><dt>Tipo de acesso</dt><dd>{profile?.role === 'TEACHER' ? 'Edição e correção' : 'Estudo e respostas'}</dd></div>
        </dl>
        <button className="button button--secondary" onClick={() => void signOut()}><LogOut size={18} /> Sair da conta</button>
      </section>
    </div>
  )
}
