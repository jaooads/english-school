import { AlertCircle, ArrowDown, ArrowLeft, ArrowUp, Plus, Save, Trash2 } from 'lucide-react'
import { useEffect, useState, type FormEvent } from 'react'
import { Link, Navigate, useNavigate, useParams } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'
import { getLesson, saveExercise } from '../services/lessons'
import type { ExerciseType } from '../types/domain'

interface EditableQuestion {
  id: string
  persisted: boolean
  question: string
  options: Array<{ option_text: string }>
}

function defaultOptions() {
  return Array.from({ length: 4 }, () => ({ option_text: '' }))
}

function newQuestion(): EditableQuestion {
  return { id: crypto.randomUUID(), persisted: false, question: '', options: defaultOptions() }
}

export function ExerciseEditorPage() {
  const { lessonId, exerciseId } = useParams()
  const navigate = useNavigate()
  const { profile } = useAuth()
  const [lessonTitle, setLessonTitle] = useState('')
  const [title, setTitle] = useState('')
  const [instructions, setInstructions] = useState('')
  const [type, setType] = useState<ExerciseType>('TEXT_INPUT')
  const [isHomework, setIsHomework] = useState(false)
  const [questions, setQuestions] = useState<EditableQuestion[]>([newQuestion()])
  const [initialQuestionIds, setInitialQuestionIds] = useState<string[]>([])
  const [position, setPosition] = useState(0)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!lessonId) return
    void getLesson(lessonId)
      .then((lesson) => {
        setLessonTitle(lesson.title)
        setPosition(lesson.exercises.length)
        if (!exerciseId) return
        const exercise = lesson.exercises.find((item) => item.id === exerciseId)
        if (!exercise) throw new Error('Este exercício não foi encontrado.')
        setTitle(exercise.title)
        setInstructions(exercise.instructions ?? '')
        setType(exercise.type)
        setIsHomework(exercise.is_homework)
        setPosition(exercise.position)
        setQuestions(exercise.questions.map((question) => ({
          id: question.id,
          persisted: true,
          question: question.question,
          options: question.question_options.map((option) => ({ option_text: option.option_text })),
        })))
        setInitialQuestionIds(exercise.questions.map((question) => question.id))
      })
      .catch((caught) => setError(caught instanceof Error ? caught.message : 'Não foi possível carregar o exercício.'))
      .finally(() => setLoading(false))
  }, [lessonId, exerciseId])

  if (profile?.role !== 'TEACHER') return <Navigate to={`/aulas/${lessonId ?? ''}`} replace />

  function moveQuestion(index: number, direction: -1 | 1) {
    const target = index + direction
    if (target < 0 || target >= questions.length) return
    setQuestions((current) => {
      const next = [...current]
      ;[next[index], next[target]] = [next[target], next[index]]
      return next
    })
  }

  function removeQuestion(id: string) {
    const question = questions.find((item) => item.id === id)
    const warning = question?.persisted
      ? 'Remover esta questão? As respostas associadas a ela também serão excluídas ao salvar.'
      : 'Remover esta questão?'
    if (!window.confirm(warning)) return
    setQuestions((current) => current.filter((item) => item.id !== id))
  }

  function changeType(nextType: ExerciseType) {
    setType(nextType)
    if (nextType === 'MULTIPLE_CHOICE') {
      setQuestions((current) => current.map((question) => question.options.length >= 2 ? question : { ...question, options: defaultOptions() }))
    }
  }

  function updateOption(questionId: string, optionIndex: number, optionText: string) {
    setQuestions((current) => current.map((question) => question.id === questionId
      ? { ...question, options: question.options.map((option, index) => index === optionIndex ? { option_text: optionText } : option) }
      : question))
  }

  function removeOption(questionId: string, optionIndex: number) {
    setQuestions((current) => current.map((question) => question.id === questionId
      ? { ...question, options: question.options.filter((_option, index) => index !== optionIndex) }
      : question))
  }

  async function handleSubmit(event: FormEvent) {
    event.preventDefault()
    if (!lessonId || saving) return
    setError(null)

    if (!title.trim()) {
      setError('Informe um título para o exercício.')
      return
    }
    if (questions.length === 0 || questions.some((question) => !question.question.trim())) {
      setError('Adicione e preencha pelo menos uma questão.')
      return
    }
    if (type === 'MULTIPLE_CHOICE' && questions.some((question) => question.options.length < 2 || question.options.some((option) => !option.option_text.trim()))) {
      setError('Cada questão de assinalar precisa ter pelo menos duas alternativas preenchidas.')
      return
    }

    setSaving(true)
    try {
      await saveExercise({
        id: exerciseId,
        lessonId,
        title: title.trim(),
        instructions: instructions.trim(),
        type,
        isHomework,
        position,
        questions,
        removedQuestionIds: initialQuestionIds.filter((id) => !questions.some((question) => question.id === id)),
      })
      navigate(`/aulas/${lessonId}`, { replace: true, state: { message: 'Atividade salva com sucesso.' } })
    } catch (caught) {
      setError(caught instanceof Error ? caught.message : 'Não foi possível salvar o exercício.')
      setSaving(false)
    }
  }

  if (loading) return <div className="page"><div className="content-state"><span className="loader" /><p>Preparando o exercício…</p></div></div>

  return (
    <div className="page page--editor">
      <Link to={`/aulas/${lessonId}`} className="back-link"><ArrowLeft size={17} /> Voltar para {lessonTitle || 'a aula'}</Link>
      <header className="editor-heading">
        <div><span className="eyebrow">{isHomework ? 'Homework' : 'Exercício'}</span><h1>{exerciseId ? 'Editar atividade' : 'Nova atividade'}</h1><p>Crie questões que o João possa responder uma a uma.</p></div>
        <button form="exercise-form" className="button button--primary button--with-icon" disabled={saving}><Save size={18} />{saving ? 'Salvando…' : 'Salvar atividade'}</button>
      </header>

      <form id="exercise-form" className="editor-form" onSubmit={handleSubmit}>
        {error && <div className="form-message form-message--error editor-error" role="alert"><AlertCircle size={18} />{error}</div>}
        <section className="editor-panel exercise-basics">
          <div className="field"><label htmlFor="exercise-title">Título</label><input id="exercise-title" value={title} onChange={(event) => setTitle(event.target.value)} placeholder="Ex.: Complete as frases" required /></div>
          <div className="field"><label htmlFor="exercise-instructions">Instruções <span>opcional</span></label><textarea id="exercise-instructions" value={instructions} onChange={(event) => setInstructions(event.target.value)} placeholder="Explique como responder…" /></div>
          <div className="exercise-options">
            <div className="field"><label htmlFor="exercise-type">Formato da resposta</label><select id="exercise-type" value={type} onChange={(event) => changeType(event.target.value as ExerciseType)}><option value="TEXT_INPUT">Resposta curta</option><option value="TEXTAREA">Resposta longa</option><option value="MULTIPLE_CHOICE">Assinalar alternativa</option></select></div>
            <label className="check-field"><input type="checkbox" checked={isHomework} onChange={(event) => setIsHomework(event.target.checked)} /><span><strong>Homework</strong><small>Mostrar esta atividade como tarefa de casa.</small></span></label>
          </div>
        </section>

        <div className="editor-section-title"><div><h2>Questões</h2><p>As respostas existentes são preservadas quando o texto é editado.</p></div></div>
        <div className="question-editors">
          {questions.map((question, index) => (
            <section className="editor-panel question-editor" key={question.id}>
              <span className="question-number">{index + 1}</span>
              <div className="field"><label htmlFor={`question-${question.id}`}>Enunciado</label><textarea id={`question-${question.id}`} value={question.question} onChange={(event) => setQuestions((current) => current.map((item) => item.id === question.id ? { ...item, question: event.target.value } : item))} placeholder="Digite a pergunta ou frase para completar…" required />
                {type === 'MULTIPLE_CHOICE' && (
                  <div className="multiple-choice-editor">
                    <span>Alternativas</span>
                    {question.options.map((option, optionIndex) => (
                      <div className="option-editor" key={optionIndex}>
                        <span>{String.fromCharCode(65 + optionIndex)}</span>
                        <input value={option.option_text} onChange={(event) => updateOption(question.id, optionIndex, event.target.value)} placeholder={`Alternativa ${String.fromCharCode(65 + optionIndex)}`} required />
                        <button type="button" className="icon-button icon-button--danger" onClick={() => removeOption(question.id, optionIndex)} disabled={question.options.length <= 2} aria-label={`Remover alternativa ${String.fromCharCode(65 + optionIndex)}`}><Trash2 size={15} /></button>
                      </div>
                    ))}
                    {question.options.length < 6 && <button type="button" className="add-option-button" onClick={() => setQuestions((current) => current.map((item) => item.id === question.id ? { ...item, options: [...item.options, { option_text: '' }] } : item))}><Plus size={15} /> Adicionar alternativa</button>}
                  </div>
                )}
              </div>
              <div className="question-editor__actions">
                <button type="button" className="icon-button" onClick={() => moveQuestion(index, -1)} disabled={index === 0} aria-label="Mover questão para cima"><ArrowUp size={17} /></button>
                <button type="button" className="icon-button" onClick={() => moveQuestion(index, 1)} disabled={index === questions.length - 1} aria-label="Mover questão para baixo"><ArrowDown size={17} /></button>
                <button type="button" className="icon-button icon-button--danger" onClick={() => removeQuestion(question.id)} aria-label="Remover questão"><Trash2 size={17} /></button>
              </div>
            </section>
          ))}
        </div>
        <button type="button" className="button button--secondary button--with-icon add-question" onClick={() => setQuestions((current) => [...current, newQuestion()])}><Plus size={18} /> Adicionar questão</button>
        <div className="mobile-save"><button className="button button--primary button--with-icon" disabled={saving}><Save size={18} />{saving ? 'Salvando…' : 'Salvar atividade'}</button></div>
      </form>
    </div>
  )
}
