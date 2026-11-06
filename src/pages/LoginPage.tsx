import { BookOpen, LockKeyhole } from 'lucide-react'
import { useState, type FormEvent } from 'react'
import { Navigate } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'

export function LoginPage() {
  const { session, loading, signIn } = useAuth()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  if (session) return <Navigate to="/" replace />

  async function handleSubmit(event: FormEvent) {
    event.preventDefault()
    if (submitting) return
    setSubmitting(true)
    setError(null)

    try {
      await signIn(email.trim(), password)
    } catch (caught) {
      setError(caught instanceof Error ? caught.message : 'Não foi possível entrar.')
      setSubmitting(false)
    }
  }

  return (
    <main className="login-page">
      <section className="login-intro">
        <div className="brand-mark"><BookOpen size={26} /></div>
        <span className="eyebrow">English School</span>
        <h1>Um lugar tranquilo para aprender, praticar e revisar.</h1>
        <p>O caderno compartilhado de João e Camila, organizado aula por aula.</p>
      </section>

      <section className="login-card" aria-labelledby="login-title">
        <div className="login-card__icon"><LockKeyhole size={22} /></div>
        <h2 id="login-title">Bem-vindo de volta</h2>
        <p>Entre com o acesso criado pela professora.</p>

        <form onSubmit={handleSubmit}>
          <label htmlFor="email">E-mail</label>
          <input
            id="email"
            type="email"
            value={email}
            onChange={(event) => setEmail(event.target.value)}
            autoComplete="email"
            placeholder="voce@exemplo.com"
            required
          />

          <label htmlFor="password">Senha</label>
          <input
            id="password"
            type="password"
            value={password}
            onChange={(event) => setPassword(event.target.value)}
            autoComplete="current-password"
            placeholder="Sua senha"
            required
          />

          {error && <div className="form-message form-message--error" role="alert">{error}</div>}

          <button className="button button--primary button--full" disabled={submitting || loading}>
            {submitting || loading ? 'Entrando…' : 'Entrar'}
          </button>
        </form>
      </section>
    </main>
  )
}
