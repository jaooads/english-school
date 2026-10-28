import { AlertCircle, ArrowRight, BookOpen, CalendarDays, Plus, RefreshCw } from 'lucide-react'
import { useEffect, useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { PageHeader } from '../components/PageHeader'
import { useAuth } from '../contexts/AuthContext'
import { formatDate, formatMonth } from '../lib/date'
import { listLessons } from '../services/lessons'
import type { Lesson } from '../types/domain'

export function LessonsPage() {
  const { profile } = useAuth()
  const [lessons, setLessons] = useState<Lesson[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  async function load() {
    setLoading(true)
    setError(null)
    try {
      setLessons(await listLessons())
    } catch (caught) {
      setError(caught instanceof Error ? caught.message : 'Não foi possível carregar as aulas.')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { void load() }, [])

  const groupedLessons = useMemo(() => {
    return lessons.reduce<Array<{ month: string; lessons: Lesson[] }>>((groups, lesson) => {
      const month = formatMonth(lesson.lesson_date)
      const current = groups.at(-1)
      if (current?.month === month) current.lessons.push(lesson)
      else groups.push({ month, lessons: [lesson] })
      return groups
    }, [])
  }, [lessons])

  return (
    <div className="page">
      <PageHeader
        eyebrow="Caderno"
        title="Aulas"
        description="Todo o conteúdo organizado pela data em que foi estudado."
        action={profile?.role === 'TEACHER' ? (
          <Link to="/aulas/nova" className="button button--primary button--with-icon"><Plus size={18} /> Nova aula</Link>
        ) : undefined}
      />

      {loading && (
        <div className="content-state" role="status"><span className="loader" /><p>Buscando as aulas…</p></div>
      )}

      {!loading && error && (
        <div className="content-state content-state--error" role="alert">
          <AlertCircle size={28} /><h2>Algo deu errado</h2><p>{error}</p>
          <button className="button button--secondary button--with-icon" onClick={() => void load()}><RefreshCw size={17} /> Tentar novamente</button>
        </div>
      )}

      {!loading && !error && lessons.length === 0 && (
        <div className="empty-state">
          <BookOpen size={30} /><h2>Nenhuma aula por aqui</h2>
          <p>{profile?.role === 'TEACHER' ? 'Crie a primeira aula para começar o caderno.' : 'A próxima aula aparecerá aqui quando a Camila criar.'}</p>
          {profile?.role === 'TEACHER' && <Link to="/aulas/nova" className="button button--primary button--with-icon"><Plus size={18} /> Criar primeira aula</Link>}
        </div>
      )}

      {!loading && !error && groupedLessons.length > 0 && (
        <div className="lesson-groups">
          {groupedLessons.map((group) => (
            <section key={group.month} className="lesson-group">
              <h2>{group.month}</h2>
              <div className="lesson-list">
                {group.lessons.map((lesson) => (
                  <Link to={`/aulas/${lesson.id}`} className="lesson-row" key={lesson.id}>
                    <span className="lesson-row__date"><CalendarDays size={18} />{formatDate(lesson.lesson_date)}</span>
                    <strong>{lesson.title}</strong>
                    <ArrowRight size={19} />
                  </Link>
                ))}
              </div>
            </section>
          ))}
        </div>
      )}
    </div>
  )
}
