import { Check, CheckCircle2, Edit3, MessageSquareText, Save, Trash2, X, XCircle } from 'lucide-react'
import { useEffect, useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { correctStudentAnswer, deleteExercise, saveStudentAnswer } from '../../services/lessons'
import type { Answer, AnswerStatus, AppRole, ExerciseWithQuestions } from '../../types/domain'

interface ExerciseCardProps {
  exercise: ExerciseWithQuestions
  lessonId: string
  role: AppRole
  onChanged: () => Promise<void> | void
}

export function ExerciseCard({ exercise, lessonId, role, onChanged }: ExerciseCardProps) {
  const answers = useMemo(() => Object.fromEntries(exercise.questions.map((question) => [question.id, question.answers[0]?.answer ?? ''])), [exercise.questions])
  const [drafts, setDrafts] = useState<Record<string, string>>(answers)
  const [saving, setSaving] = useState(false)
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null)

  useEffect(() => setDrafts(answers), [answers])

  async function handleStudentSave() {
    if (saving) return
    const changed = exercise.questions.filter((question) => {
      const draft = drafts[question.id]?.trim() ?? ''
      return draft && draft !== (question.answers[0]?.answer ?? '')
    })

    if (changed.length === 0) {
      setMessage({ type: 'error', text: 'Escreva ou altere pelo menos uma resposta antes de salvar.' })
      return
    }

    setSaving(true)
    setMessage(null)
    try {
      await Promise.all(changed.map((question) => saveStudentAnswer(question.id, drafts[question.id])))
      setMessage({ type: 'success', text: changed.length === 1 ? 'Resposta salva.' : `${changed.length} respostas salvas.` })
      await onChanged()
    } catch (caught) {
      setMessage({ type: 'error', text: caught instanceof Error ? caught.message : 'Não foi possível salvar as respostas.' })
    } finally {
      setSaving(false)
    }
  }

  async function handleDelete() {
    if (!window.confirm(`Excluir “${exercise.title}”? As respostas desta atividade também serão removidas.`)) return
    setSaving(true)
    try {
      await deleteExercise(exercise.id)
      await onChanged()
    } catch (caught) {
      setMessage({ type: 'error', text: caught instanceof Error ? caught.message : 'Não foi possível excluir a atividade.' })
      setSaving(false)
    }
  }

  const answered = exercise.questions.filter((question) => question.answers.length > 0).length

  return (
    <section className={`exercise-card ${exercise.is_homework ? 'exercise-card--homework' : ''}`}>
      <header className="exercise-card__header">
        <div>
          <span>{exercise.is_homework ? 'Homework' : 'Exercise'} · {answered}/{exercise.questions.length} respondidas</span>
          <h3>{exercise.title}</h3>
          {exercise.instructions && <p>{exercise.instructions}</p>}
        </div>
        {role === 'TEACHER' && (
          <div className="exercise-card__actions">
            <Link to={`/aulas/${lessonId}/exercicios/${exercise.id}/editar`} className="icon-button" aria-label="Editar atividade"><Edit3 size={17} /></Link>
            <button className="icon-button icon-button--danger" onClick={() => void handleDelete()} disabled={saving} aria-label="Excluir atividade"><Trash2 size={17} /></button>
          </div>
        )}
      </header>

      <div className="exercise-questions">
        {exercise.questions.map((question, index) => {
          const answer = question.answers[0]
          return (
            <div className="study-question" key={question.id}>
              <div className="study-question__prompt"><span>{index + 1}</span><p>{question.question}</p></div>
              {role === 'STUDENT' ? (
                <>
                  {exercise.type === 'TEXTAREA' ? (
                    <textarea value={drafts[question.id] ?? ''} onChange={(event) => setDrafts((current) => ({ ...current, [question.id]: event.target.value }))} placeholder="Escreva sua resposta…" />
                  ) : (
                    <input value={drafts[question.id] ?? ''} onChange={(event) => setDrafts((current) => ({ ...current, [question.id]: event.target.value }))} placeholder="Sua resposta…" />
                  )}
                  {answer && <StudentCorrection answer={answer} />}
                </>
              ) : answer ? (
                <TeacherCorrection answer={answer} onChanged={onChanged} />
              ) : (
                <div className="unanswered-note">João ainda não respondeu esta questão.</div>
              )}
            </div>
          )
        })}
      </div>

      {role === 'STUDENT' && (
        <footer className="exercise-card__footer">
          {message && <span className={`save-message save-message--${message.type}`} role="status">{message.type === 'success' ? <Check size={16} /> : <X size={16} />}{message.text}</span>}
          <button className="button button--primary button--with-icon" onClick={() => void handleStudentSave()} disabled={saving}><Save size={17} />{saving ? 'Salvando…' : 'Salvar respostas'}</button>
        </footer>
      )}
    </section>
  )
}

function StudentCorrection({ answer }: { answer: Answer }) {
  if (answer.status === 'PENDING') return <div className="answer-status answer-status--pending"><MessageSquareText size={16} /> Aguardando correção da Camila</div>

  return (
    <div className={`correction-result correction-result--${answer.status.toLowerCase()}`}>
      <strong>{answer.status === 'CORRECT' ? <><CheckCircle2 size={17} /> Correto</> : <><XCircle size={17} /> Vamos revisar</>}</strong>
      {answer.corrected_answer && <p><span>Resposta correta</span>{answer.corrected_answer}</p>}
      {answer.teacher_feedback && <p><span>Comentário da Camila</span>{answer.teacher_feedback}</p>}
    </div>
  )
}

function TeacherCorrection({ answer, onChanged }: { answer: Answer; onChanged: () => Promise<void> | void }) {
  const [status, setStatus] = useState<Exclude<AnswerStatus, 'PENDING'> | null>(answer.status === 'PENDING' ? null : answer.status)
  const [correctedAnswer, setCorrectedAnswer] = useState(answer.corrected_answer ?? '')
  const [feedback, setFeedback] = useState(answer.teacher_feedback ?? '')
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)

  async function saveCorrection(nextStatus?: Exclude<AnswerStatus, 'PENDING'>) {
    const chosenStatus = nextStatus ?? status
    if (!chosenStatus || saving) return
    setStatus(chosenStatus)
    setSaving(true)
    setError(null)
    try {
      await correctStudentAnswer(answer.id, chosenStatus, correctedAnswer, feedback)
      await onChanged()
    } catch (caught) {
      setError(caught instanceof Error ? caught.message : 'Não foi possível salvar a correção.')
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="teacher-correction">
      <div className="student-answer"><span>Resposta do João</span><p>{answer.answer}</p></div>
      <div className="correction-choice">
        <button type="button" className={status === 'CORRECT' ? 'selected-correct' : ''} onClick={() => void saveCorrection('CORRECT')} disabled={saving}><CheckCircle2 size={17} /> Correta</button>
        <button type="button" className={status === 'INCORRECT' ? 'selected-incorrect' : ''} onClick={() => setStatus('INCORRECT')} disabled={saving}><XCircle size={17} /> Incorreta</button>
      </div>
      {status === 'INCORRECT' && <label>Resposta correta <input value={correctedAnswer} onChange={(event) => setCorrectedAnswer(event.target.value)} placeholder="Como deveria ficar?" /></label>}
      <label>Comentário <textarea value={feedback} onChange={(event) => setFeedback(event.target.value)} placeholder="Deixe uma orientação para o João…" /></label>
      <div className="teacher-correction__save">
        {error && <span className="save-message save-message--error"><X size={16} />{error}</span>}
        <button type="button" className="button button--secondary button--with-icon" onClick={() => void saveCorrection()} disabled={!status || saving}><Save size={16} />{saving ? 'Salvando…' : 'Salvar correção'}</button>
      </div>
    </div>
  )
}
