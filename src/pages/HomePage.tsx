import { ArrowRight, BookOpen, CheckCircle2, ClipboardList, Clock3, Plus, Sparkles } from 'lucide-react'
import { useEffect, useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'
import { formatDate } from '../lib/date'
import { getExerciseProgress } from '../lib/progress'
import { listExerciseOverview, listLessons, type ExerciseOverview } from '../services/lessons'
import type { Lesson } from '../types/domain'

export function HomePage() {
  const { profile } = useAuth()
  const firstName = profile?.name.split(' ')[0]
  const [lessons, setLessons] = useState<Lesson[]>([])
  const [exercises, setExercises] = useState<ExerciseOverview[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(false)

  useEffect(() => {
    void Promise.all([listLessons(), listExerciseOverview()])
      .then(([lessonData, exerciseData]) => {
        setLessons(lessonData)
        setExercises(exerciseData)
      })
      .catch(() => setError(true))
      .finally(() => setLoading(false))
  }, [])

  const nextExercise = useMemo(() => exercises.find((exercise) => {
    const progress = getExerciseProgress(exercise)
    return profile?.role === 'TEACHER' ? progress.pendingCorrection : !progress.complete
  }), [exercises, profile?.role])

  const correctedCount = exercises.filter((exercise) => getExerciseProgress(exercise).complete).length
  const pendingCount = exercises.length - correctedCount
  const nextProgress = nextExercise ? getExerciseProgress(nextExercise) : null

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

      {!loading && !error && (
        <section className="next-step" aria-labelledby="next-step-title">
          <div className="next-step__label"><Clock3 size={17} /> Próximo passo</div>
          {nextExercise ? (
            <>
              <div className="next-step__content">
                <div>
                  <span>{profile?.role === 'TEACHER' ? 'Há respostas esperando por você' : nextExercise.is_homework ? 'Homework em andamento' : 'Continue praticando'}</span>
                  <h2 id="next-step-title">{nextExercise.title}</h2>
                  <p>{nextExercise.lessons.title} · {formatDate(nextExercise.lessons.lesson_date)}</p>
                </div>
                <div className="next-step__progress" aria-label={`${nextProgress?.percentage ?? 0}% respondido`}>
                  <strong>{nextProgress?.answered}/{nextProgress?.total}</strong>
                  <span>respondidas</span>
                </div>
              </div>
              <div className="progress-track"><span style={{ width: `${nextProgress?.percentage ?? 0}%` }} /></div>
              <Link to={`/aulas/${nextExercise.lessons.id}`} className="button button--primary button--with-icon">
                {profile?.role === 'TEACHER' ? 'Corrigir agora' : 'Continuar atividade'} <ArrowRight size={17} />
              </Link>
            </>
          ) : lessons[0] ? (
            <>
              <div className="next-step__content">
                <div><span>{profile?.role === 'TEACHER' ? 'Tudo acompanhado' : 'Revisão sugerida'}</span><h2 id="next-step-title">{lessons[0].title}</h2><p>Última aula · {formatDate(lessons[0].lesson_date)}</p></div>
                <CheckCircle2 className="next-step__complete" size={34} />
              </div>
              <Link to={profile?.role === 'TEACHER' ? '/aulas/nova' : `/aulas/${lessons[0].id}`} className="button button--primary button--with-icon">
                {profile?.role === 'TEACHER' ? <><Plus size={17} /> Preparar nova aula</> : <>Revisar aula <ArrowRight size={17} /></>}
              </Link>
            </>
          ) : (
            <><h2 id="next-step-title">O caderno está pronto para começar.</h2>{profile?.role === 'TEACHER' && <Link to="/aulas/nova" className="button button--primary button--with-icon"><Plus size={17} /> Criar primeira aula</Link>}</>
          )}
        </section>
      )}

      {!loading && !error && (
        <div className="learning-stats" aria-label="Resumo do caderno">
          <div><BookOpen size={19} /><strong>{lessons.length}</strong><span>{lessons.length === 1 ? 'aula' : 'aulas'}</span></div>
          <div><Clock3 size={19} /><strong>{pendingCount}</strong><span>pendentes</span></div>
          <div><CheckCircle2 size={19} /><strong>{correctedCount}</strong><span>corrigidos</span></div>
        </div>
      )}

      {error && <div className="home-data-error">Não foi possível carregar o resumo agora. As aulas continuam disponíveis pelos atalhos abaixo.</div>}

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
