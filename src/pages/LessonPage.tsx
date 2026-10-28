import { AlertCircle, ArrowLeft, CalendarDays, Edit3, Plus, RefreshCw, Trash2 } from 'lucide-react'
import { useEffect, useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'
import { LessonBlockCard, LessonSectionMarker } from '../components/lessons/LessonBlockCard'
import { ExerciseCard } from '../components/exercises/ExerciseCard'
import { useAuth } from '../contexts/AuthContext'
import { formatDate } from '../lib/date'
import { deleteLesson, getLesson } from '../services/lessons'
import type { LessonDetail } from '../types/domain'

export function LessonPage() {
  const { lessonId } = useParams()
  const navigate = useNavigate()
  const { profile } = useAuth()
  const [lesson, setLesson] = useState<LessonDetail | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [deleting, setDeleting] = useState(false)

  async function load() {
    if (!lessonId) return
    setLoading(true)
    setError(null)
    try {
      setLesson(await getLesson(lessonId))
    } catch (caught) {
      setError(caught instanceof Error ? caught.message : 'Não foi possível carregar a aula.')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { void load() }, [lessonId])

  async function handleDelete() {
    if (!lesson || deleting) return
    const confirmed = window.confirm(`Excluir a aula “${lesson.title}”? Todo o conteúdo e as respostas desta aula serão removidos.`)
    if (!confirmed) return
    setDeleting(true)
    try {
      await deleteLesson(lesson.id)
      navigate('/aulas', { replace: true })
    } catch (caught) {
      setError(caught instanceof Error ? caught.message : 'Não foi possível excluir a aula.')
      setDeleting(false)
    }
  }

  if (loading) return <div className="page"><div className="content-state"><span className="loader" /><p>Abrindo a aula…</p></div></div>

  if (error || !lesson) {
    return (
      <div className="page page--reading"><div className="content-state content-state--error" role="alert">
        <AlertCircle size={28} /><h2>Aula indisponível</h2><p>{error ?? 'Esta aula não foi encontrada.'}</p>
        <button className="button button--secondary button--with-icon" onClick={() => void load()}><RefreshCw size={17} /> Tentar novamente</button>
      </div></div>
    )
  }

  const classExercises = lesson.exercises.filter((exercise) => !exercise.is_homework)
  const homework = lesson.exercises.filter((exercise) => exercise.is_homework)

  return (
    <article className="page page--reading lesson-page">
      <Link to="/aulas" className="back-link"><ArrowLeft size={17} /> Voltar para aulas</Link>
      <header className="lesson-heading">
        <div>
          <span className="lesson-heading__date"><CalendarDays size={17} /> {formatDate(lesson.lesson_date)}</span>
          <h1>{lesson.title}</h1>
        </div>
        {profile?.role === 'TEACHER' && (
          <div className="lesson-heading__actions">
            <Link to={`/aulas/${lesson.id}/editar`} className="button button--secondary button--with-icon"><Edit3 size={17} /> Editar</Link>
            <button className="icon-button icon-button--danger" onClick={() => void handleDelete()} disabled={deleting} aria-label="Excluir aula"><Trash2 size={18} /></button>
          </div>
        )}
      </header>

      <div className="lesson-content">
        {lesson.lesson_blocks.length === 0 && <div className="lesson-empty">Esta aula ainda não tem conteúdo.</div>}
        {lesson.lesson_blocks.map((block) => <LessonBlockCard key={block.id} block={block} />)}

        {profile?.role === 'TEACHER' && (
          <div className="exercise-add-row"><Link to={`/aulas/${lesson.id}/exercicios/novo`} className="button button--secondary button--with-icon"><Plus size={17} /> Adicionar exercício ou homework</Link></div>
        )}

        {classExercises.length > 0 && (
          <section className="study-section">
            <LessonSectionMarker />
            {classExercises.map((exercise) => (
              <ExerciseCard key={exercise.id} exercise={exercise} lessonId={lesson.id} role={profile!.role} onChanged={load} />
            ))}
          </section>
        )}

        {homework.length > 0 && (
          <section className="study-section study-section--homework">
            <LessonSectionMarker homework />
            {homework.map((exercise) => (
              <ExerciseCard key={exercise.id} exercise={exercise} lessonId={lesson.id} role={profile!.role} onChanged={load} />
            ))}
          </section>
        )}
      </div>
    </article>
  )
}
