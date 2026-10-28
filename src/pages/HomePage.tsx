import { ArrowRight, BookOpen, ClipboardList, Sparkles } from 'lucide-react'
import { Link } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'

export function HomePage() {
  const { profile } = useAuth()
  const firstName = profile?.name.split(' ')[0]

  return (
    <div className="page page--home">
      <section className="home-hero">
        <span className="home-hero__icon"><Sparkles size={21} /></span>
        <div>
          <span className="eyebrow">Seu caderno compartilhado</span>
          <h1>Olá, {firstName}.</h1>
          <p>{profile?.role === 'TEACHER' ? 'Organize a próxima aula ou acompanhe as respostas do João.' : 'Continue de onde parou ou revise uma correção da Camila.'}</p>
        </div>
      </section>

      <div className="quick-grid">
        <Link to="/aulas" className="quick-card">
          <span className="quick-card__icon"><BookOpen size={24} /></span>
          <div><strong>Aulas</strong><p>Conteúdo organizado por data, do mais recente ao mais antigo.</p></div>
          <ArrowRight size={20} />
        </Link>
        <Link to="/exercicios" className="quick-card">
          <span className="quick-card__icon quick-card__icon--green"><ClipboardList size={24} /></span>
          <div><strong>Exercícios</strong><p>Responda, continue atividades pendentes e revise correções.</p></div>
          <ArrowRight size={20} />
        </Link>
      </div>

      <section className="study-note">
        <span>Small steps, every day.</span>
        <p>O progresso acontece quando praticar vira parte da rotina.</p>
      </section>
    </div>
  )
}
