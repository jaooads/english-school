import { AlertCircle, BookOpen } from 'lucide-react'

interface FullPageStateProps {
  title?: string
  message?: string
  error?: boolean
}

export function FullPageState({
  title = 'Carregando seu caderno…',
  message,
  error = false,
}: FullPageStateProps) {
  return (
    <main className="full-page-state" role={error ? 'alert' : 'status'}>
      <div className={`state-icon ${error ? 'state-icon--error' : ''}`}>
        {error ? <AlertCircle size={26} /> : <BookOpen size={26} />}
      </div>
      <h1>{title}</h1>
      {message && <p>{message}</p>}
      {!error && <span className="loader" aria-hidden="true" />}
    </main>
  )
}
