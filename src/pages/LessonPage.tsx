import { AlertCircle, ArrowLeft, BookOpenCheck, CalendarDays, CheckCircle2, Edit3, GraduationCap, ListChecks, Plus, RefreshCw, Target, Trash2 } from 'lucide-react'
import { useEffect, useState } from 'react'
import { Link, useLocation, useNavigate, useParams } from 'react-router-dom'
import { getLessonBlockLabel, LessonBlockCard, LessonSectionMarker } from '../components/lessons/LessonBlockCard'
import { ExerciseCard } from '../components/exercises/ExerciseCard'
import { useAuth } from '../contexts/AuthContext'
import { formatDate } from '../lib/date'
import { deleteLesson, getLesson } from '../services/lessons'
import type { LessonDetail } from '../types/domain'

export function LessonPage() {
  const { lessonId } = useParams()
  const navigate = useNavigate()
  const location = useLocation()
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
      navigate('/aulas', { replace: true, state: { message: 'Aula excluída com sucesso.' } })
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
  const totalQuestions = lesson.exercises.reduce((total, exercise) => total + exercise.questions.length, 0)
  const answeredQuestions = lesson.exercises.reduce((total, exercise) => total + exercise.questions.filter((question) => question.answers.length > 0).length, 0)
  const visibleBlocks = lesson.lesson_blocks.filter((block) => !block.title?.toLocaleLowerCase('pt-BR').startsWith('identifica'))
  const blockSteps = new Map(visibleBlocks.map((block, index) => [block.id, index + 1]))
  const roadmap = Array.from(new Set(visibleBlocks.map((block) => block.type))).map((type) => ({
    type,
    label: getLessonBlockLabel(type),
    count: visibleBlocks.filter((block) => block.type === type).length,
    target: `block-${visibleBlocks.find((block) => block.type === type)!.id}`,
  }))

  return (
    <article className="page page--reading lesson-page">
      <Link to="/aulas" className="back-link"><ArrowLeft size={17} /> Voltar para aulas</Link>
      {location.state?.message && <div className="form-message form-message--success page-message" role="status"><CheckCircle2 size={18} />{location.state.message}</div>}
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

      <section className="lesson-overview" aria-label="Visão geral da aula">
        <div className="lesson-overview__intro">
          <span><Target size={17} /> Nesta aula</span>
          <p>Siga o roteiro na ordem e use os exercícios para fixar o conteúdo.</p>
        </div>
        <div className="lesson-overview__stats">
          <div><BookOpenCheck size={19} /><strong>{visibleBlocks.length}</strong><span>etapas de conteúdo</span></div>
          <div><ListChecks size={19} /><strong>{lesson.exercises.length}</strong><span>atividades</span></div>
          <div><GraduationCap size={19} /><strong>{answeredQuestions}/{totalQuestions}</strong><span>questões respondidas</span></div>
        </div>
      </section>

      <div className="lesson-study-layout">
        <aside className="lesson-roadmap" aria-label="Roteiro da aula">
          <span className="lesson-roadmap__title">Roteiro</span>
          <nav>
            {roadmap.map((item) => <a key={item.type} href={`#${item.target}`}><span>{item.label}</span><small>{item.count}</small></a>)}
            {classExercises.length > 0 && <a href="#class-exercises"><span>Exercises</span><small>{classExercises.length}</small></a>}
            {homework.length > 0 && <a href="#lesson-homework"><span>Homework</span><small>{homework.length}</small></a>}
          </nav>
          <p>Estude de cima para baixo. Você pode voltar a qualquer parte quando precisar.</p>
        </aside>

        <div className="lesson-content">
          {lesson.lesson_blocks.length === 0 && <div className="lesson-empty">Esta aula ainda não tem conteúdo.</div>}
          {lesson.lesson_blocks.map((block) => <LessonBlockCard key={block.id} block={block} step={blockSteps.get(block.id) ?? 0} />)}

          {profile?.role === 'TEACHER' && (
            <div className="exercise-add-row"><Link to={`/aulas/${lesson.id}/exercicios/novo`} className="button button--secondary button--with-icon"><Plus size={17} /> Adicionar exercício ou homework</Link></div>
          )}

          {classExercises.length > 0 && (
            <section id="class-exercises" className="study-section">
              <LessonSectionMarker />
              <p className="study-section__intro">Agora é hora de aplicar o que apareceu nas etapas acima.</p>
              {classExercises.map((exercise) => (
                <ExerciseCard key={exercise.id} exercise={exercise} lessonId={lesson.id} role={profile!.role} onChanged={load} />
              ))}
            </section>
          )}

          {homework.length > 0 && (
            <section id="lesson-homework" className="study-section study-section--homework">
              <LessonSectionMarker homework />
              <p className="study-section__intro">Faça com calma depois da aula e salve mesmo que ainda não tenha terminado.</p>
              {homework.map((exercise) => (
                <ExerciseCard key={exercise.id} exercise={exercise} lessonId={lesson.id} role={profile!.role} onChanged={load} />
              ))}
            </section>
          )}
        </div>
      </div>
    </article>
  )
}
