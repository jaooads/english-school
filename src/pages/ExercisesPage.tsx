import { AlertCircle, ArrowRight, CheckCircle2, ClipboardList, RefreshCw } from 'lucide-react'
import { useEffect, useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { PageHeader } from '../components/PageHeader'
import { useAuth } from '../contexts/AuthContext'
import { formatDate } from '../lib/date'
import { getExerciseProgress } from '../lib/progress'
import { listExerciseOverview, type ExerciseOverview } from '../services/lessons'

type Filter = 'ALL' | 'PENDING' | 'CORRECTED'

export function ExercisesPage() {
  const { profile } = useAuth()
  const [exercises, setExercises] = useState<ExerciseOverview[]>([])
  const [filter, setFilter] = useState<Filter>('ALL')
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  async function load() {
    setLoading(true)
    setError(null)
    try {
      setExercises(await listExerciseOverview())
    } catch (caught) {
      setError(caught instanceof Error ? caught.message : 'Não foi possível carregar os exercícios.')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { void load() }, [])

  const filtered = useMemo(() => exercises.filter((exercise) => {
    if (filter === 'ALL') return true
    const progress = getExerciseProgress(exercise)
    return filter === 'CORRECTED' ? progress.complete : !progress.complete
  }), [exercises, filter])

  return (
    <div className="page">
      <PageHeader eyebrow="Prática" title="Exercícios" description="Continue atividades pendentes ou revise o que já foi corrigido." />

      <div className="filter-tabs" role="group" aria-label="Filtrar exercícios">
        {([['ALL', 'Todos'], ['PENDING', 'Pendentes'], ['CORRECTED', 'Corrigidos']] as const).map(([value, label]) => (
          <button key={value} className={filter === value ? 'filter-tab filter-tab--active' : 'filter-tab'} onClick={() => setFilter(value)}>{label}</button>
        ))}
      </div>

      {loading && <div className="content-state"><span className="loader" /><p>Reunindo os exercícios…</p></div>}
      {!loading && error && <div className="content-state content-state--error" role="alert"><AlertCircle size={28} /><h2>Algo deu errado</h2><p>{error}</p><button className="button button--secondary button--with-icon" onClick={() => void load()}><RefreshCw size={17} /> Tentar novamente</button></div>}
      {!loading && !error && exercises.length === 0 && <div className="empty-state"><ClipboardList size={30} /><h2>Nenhum exercício ainda</h2><p>As atividades criadas nas aulas aparecerão reunidas aqui.</p></div>}
      {!loading && !error && exercises.length > 0 && filtered.length === 0 && <div className="empty-state"><CheckCircle2 size={30} /><h2>Nada neste filtro</h2><p>Escolha outro filtro para ver as demais atividades.</p></div>}

      {!loading && !error && filtered.length > 0 && (
        <div className="overview-list">
          {filtered.map((exercise) => {
            const progress = getExerciseProgress(exercise)
            const status = progress.complete ? 'Corrigido' : progress.pendingCorrection ? 'Aguardando correção' : progress.answered > 0 ? 'Em andamento' : 'Pendente'
            const action = profile?.role === 'TEACHER'
              ? (progress.pendingCorrection ? 'Corrigir' : 'Abrir')
              : (progress.complete ? 'Revisar' : 'Continuar')
            return (
              <article className="overview-card" key={exercise.id}>
                <div className="overview-card__main">
                  <span className={`overview-card__kind ${exercise.is_homework ? 'overview-card__kind--homework' : ''}`}>{exercise.is_homework ? 'Homework' : 'Exercise'}</span>
                  <h2>{exercise.title}</h2>
                  <p>{exercise.lessons.title} · {formatDate(exercise.lessons.lesson_date)}</p>
                </div>
                <div className="overview-card__progress">
                  <span className={`status-pill ${progress.complete ? 'status-pill--correct' : progress.pendingCorrection ? 'status-pill--waiting' : ''}`}>{status}</span>
                  <strong>{progress.answered}/{exercise.questions.length}</strong><small>respondidas</small>
                </div>
                <Link to={`/aulas/${exercise.lessons.id}`} className="button button--secondary button--with-icon">{action}<ArrowRight size={17} /></Link>
              </article>
            )
          })}
        </div>
      )}
    </div>
  )
}
