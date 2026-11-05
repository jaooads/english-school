import { Check, CheckCircle2, Edit3, MessageSquareText, Save, Trash2, X, XCircle } from 'lucide-react'
import { useEffect, useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { getExerciseProgress } from '../../lib/progress'
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
  const progress = getExerciseProgress(exercise)

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
    <section id={`exercise-${exercise.id}`} className={`exercise-card ${exercise.is_homework ? 'exercise-card--homework' : ''}`}>
      <header className="exercise-card__header">
        <div>
          <span>{exercise.is_homework ? 'Homework' : 'Exercise'} · {answered}/{exercise.questions.length} respondidas</span>
          <h3>{exercise.title}</h3>
          {exercise.instructions && <p>{exercise.instructions}</p>}
          <div className="exercise-progress" aria-label={`${progress.percentage}% respondido`}>
            <div><span style={{ width: `${progress.percentage}%` }} /></div>
            <small>{progress.percentage}%</small>
          </div>
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
            <div className={`study-question ${answer ? 'study-question--answered' : ''}`} key={question.id}>
              <div className="study-question__prompt">
                <span>{index + 1}</span>
                <div><small>Questão {index + 1}</small><p>{question.question}</p></div>
                {answer && <QuestionStatus status={answer.status} />}
              </div>
              {role === 'STUDENT' ? (
                <>
                  {exercise.type === 'MULTIPLE_CHOICE' ? (
                    <fieldset className="choice-list">
                      <legend>Sua resposta</legend>
                      {question.question_options.map((option, optionIndex) => (
                        <label key={option.id} className={drafts[question.id] === option.option_text ? 'choice-option choice-option--selected' : 'choice-option'}>
                          <input
                            type="radio"
                            name={`answer-${question.id}`}
                            value={option.option_text}
                            checked={drafts[question.id] === option.option_text}
                            onChange={(event) => setDrafts((current) => ({ ...current, [question.id]: event.target.value }))}
                          />
                          <span>{String.fromCharCode(65 + optionIndex)}</span>
                          <strong>{option.option_text}</strong>
                        </label>
                      ))}
                    </fieldset>
                  ) : <label className="answer-field" htmlFor={`answer-${question.id}`}>
                    <span>Sua resposta</span>
                  {exercise.type === 'TEXTAREA' ? (
                    <textarea id={`answer-${question.id}`} value={drafts[question.id] ?? ''} onChange={(event) => setDrafts((current) => ({ ...current, [question.id]: event.target.value }))} placeholder="Escreva sua resposta…" />
                  ) : (
                    <input id={`answer-${question.id}`} value={drafts[question.id] ?? ''} onChange={(event) => setDrafts((current) => ({ ...current, [question.id]: event.target.value }))} placeholder="Digite sua resposta…" />
                  )}
                  </label>}
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
          <div>
            {message ? <span className={`save-message save-message--${message.type}`} role="status">{message.type === 'success' ? <Check size={16} /> : <X size={16} />}{message.text}</span> : <span className="save-hint">Você pode salvar agora e continuar depois.</span>}
          </div>
          <button className="button button--primary button--with-icon" onClick={() => void handleStudentSave()} disabled={saving}><Save size={17} />{saving ? 'Salvando…' : 'Salvar progresso'}</button>
        </footer>
      )}
    </section>
  )
}

function QuestionStatus({ status }: { status: AnswerStatus }) {
  const label = status === 'CORRECT' ? 'Correta' : status === 'INCORRECT' ? 'Revisar' : 'Salva'
  return <span className={`question-status question-status--${status.toLowerCase()}`}>{status === 'CORRECT' ? <CheckCircle2 size={14} /> : status === 'INCORRECT' ? <XCircle size={14} /> : <Save size={13} />}{label}</span>
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
        <button type="button" className={status === 'CORRECT' ? 'selected-correct' : ''} onClick={() => setStatus('CORRECT')} disabled={saving} aria-pressed={status === 'CORRECT'}><CheckCircle2 size={17} /> Correta</button>
        <button type="button" className={status === 'INCORRECT' ? 'selected-incorrect' : ''} onClick={() => setStatus('INCORRECT')} disabled={saving} aria-pressed={status === 'INCORRECT'}><XCircle size={17} /> Precisa revisar</button>
      </div>
      {status === 'INCORRECT' && <label>Resposta correta <input value={correctedAnswer} onChange={(event) => setCorrectedAnswer(event.target.value)} placeholder="Como deveria ficar?" /></label>}
      <label>Comentário para o João <span className="optional-label">opcional</span><textarea value={feedback} onChange={(event) => setFeedback(event.target.value)} placeholder="Explique o que ele acertou ou como pode melhorar…" /></label>
      <div className="teacher-correction__save">
        {error && <span className="save-message save-message--error"><X size={16} />{error}</span>}
        <button type="button" className="button button--secondary button--with-icon" onClick={() => void saveCorrection()} disabled={!status || saving}><Save size={16} />{saving ? 'Salvando…' : 'Salvar correção'}</button>
      </div>
    </div>
  )
}
