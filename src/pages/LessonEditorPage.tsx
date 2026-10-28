import { AlertCircle, ArrowDown, ArrowLeft, ArrowUp, Plus, Save, Trash2 } from 'lucide-react'
import { useEffect, useState, type FormEvent } from 'react'
import { Link, Navigate, useNavigate, useParams } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'
import { todayInputValue } from '../lib/date'
import { getLesson, saveLesson } from '../services/lessons'
import type { LessonBlockType } from '../types/domain'

interface EditableBlock {
  id: string
  persisted: boolean
  type: LessonBlockType
  title: string
  content: string
}

const blockOptions: Array<{ type: LessonBlockType; label: string }> = [
  { type: 'TEXT', label: 'Texto' },
  { type: 'GRAMMAR', label: 'Grammar' },
  { type: 'VOCABULARY', label: 'Vocabulary' },
  { type: 'EXAMPLE', label: 'Examples' },
  { type: 'LINK', label: 'Link' },
]

function newBlock(type: LessonBlockType): EditableBlock {
  return { id: crypto.randomUUID(), persisted: false, type, title: '', content: '' }
}

export function LessonEditorPage() {
  const { lessonId } = useParams()
  const isEditing = Boolean(lessonId)
  const navigate = useNavigate()
  const { profile } = useAuth()
  const [title, setTitle] = useState('')
  const [lessonDate, setLessonDate] = useState(todayInputValue())
  const [blocks, setBlocks] = useState<EditableBlock[]>([])
  const [initialBlockIds, setInitialBlockIds] = useState<string[]>([])
  const [loading, setLoading] = useState(isEditing)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!lessonId) return
    void getLesson(lessonId)
      .then((lesson) => {
        setTitle(lesson.title)
        setLessonDate(lesson.lesson_date)
        setBlocks(lesson.lesson_blocks.map((block) => ({
          id: block.id,
          persisted: true,
          type: block.type,
          title: block.title ?? '',
          content: block.content,
        })))
        setInitialBlockIds(lesson.lesson_blocks.map((block) => block.id))
      })
      .catch((caught) => setError(caught instanceof Error ? caught.message : 'Não foi possível carregar a aula.'))
      .finally(() => setLoading(false))
  }, [lessonId])

  if (profile?.role !== 'TEACHER') return <Navigate to="/aulas" replace />

  function updateBlock(id: string, field: 'title' | 'content' | 'type', value: string) {
    setBlocks((current) => current.map((block) => block.id === id ? { ...block, [field]: value } : block))
  }

  function moveBlock(index: number, direction: -1 | 1) {
    const target = index + direction
    if (target < 0 || target >= blocks.length) return
    setBlocks((current) => {
      const next = [...current]
      ;[next[index], next[target]] = [next[target], next[index]]
      return next
    })
  }

  function removeBlock(id: string) {
    if (!window.confirm('Remover este bloco da aula? A alteração será aplicada ao salvar.')) return
    setBlocks((current) => current.filter((block) => block.id !== id))
  }

  async function handleSubmit(event: FormEvent) {
    event.preventDefault()
    if (saving || !profile) return
    setError(null)

    if (!title.trim() || !lessonDate) {
      setError('Preencha o título e a data da aula.')
      return
    }
    if (blocks.some((block) => !block.content.trim())) {
      setError('Preencha o conteúdo de todos os blocos ou remova os blocos vazios.')
      return
    }

    setSaving(true)
    try {
      const savedId = await saveLesson({
        id: lessonId,
        title: title.trim(),
        lessonDate,
        createdBy: profile.id,
        blocks,
        removedBlockIds: initialBlockIds.filter((id) => !blocks.some((block) => block.id === id)),
      })
      navigate(`/aulas/${savedId}`, { replace: true })
    } catch (caught) {
      setError(caught instanceof Error ? caught.message : 'Não foi possível salvar a aula.')
      setSaving(false)
    }
  }

  if (loading) return <div className="page"><div className="content-state"><span className="loader" /><p>Preparando o editor…</p></div></div>

  return (
    <div className="page page--editor">
      <Link to={lessonId ? `/aulas/${lessonId}` : '/aulas'} className="back-link"><ArrowLeft size={17} /> Cancelar e voltar</Link>
      <header className="editor-heading">
        <div><span className="eyebrow">Área da professora</span><h1>{isEditing ? 'Editar aula' : 'Nova aula'}</h1><p>Organize o conteúdo em blocos simples, seguindo o fluxo da aula.</p></div>
        <button form="lesson-form" className="button button--primary button--with-icon" disabled={saving}><Save size={18} />{saving ? 'Salvando…' : 'Salvar aula'}</button>
      </header>

      <form id="lesson-form" className="editor-form" onSubmit={handleSubmit}>
        {error && <div className="form-message form-message--error editor-error" role="alert"><AlertCircle size={18} />{error}</div>}
        <section className="editor-panel editor-basics">
          <div className="field field--wide"><label htmlFor="lesson-title">Título da aula</label><input id="lesson-title" value={title} onChange={(event) => setTitle(event.target.value)} placeholder="Ex.: Simple Past — Questions" required /></div>
          <div className="field"><label htmlFor="lesson-date">Data</label><input id="lesson-date" type="date" value={lessonDate} onChange={(event) => setLessonDate(event.target.value)} required /></div>
        </section>

        <div className="editor-section-title"><div><h2>Conteúdo da aula</h2><p>Use um bloco para cada parte importante.</p></div></div>

        <div className="editor-blocks">
          {blocks.map((block, index) => (
            <section className="editor-panel editor-block" key={block.id}>
              <div className="editor-block__toolbar">
                <select aria-label="Tipo de bloco" value={block.type} onChange={(event) => updateBlock(block.id, 'type', event.target.value)}>
                  {blockOptions.map((option) => <option key={option.type} value={option.type}>{option.label}</option>)}
                </select>
                <div>
                  <button type="button" className="icon-button" onClick={() => moveBlock(index, -1)} disabled={index === 0} aria-label="Mover bloco para cima"><ArrowUp size={17} /></button>
                  <button type="button" className="icon-button" onClick={() => moveBlock(index, 1)} disabled={index === blocks.length - 1} aria-label="Mover bloco para baixo"><ArrowDown size={17} /></button>
                  <button type="button" className="icon-button icon-button--danger" onClick={() => removeBlock(block.id)} aria-label="Remover bloco"><Trash2 size={17} /></button>
                </div>
              </div>
              <div className="field"><label htmlFor={`block-title-${block.id}`}>Título <span>opcional</span></label><input id={`block-title-${block.id}`} value={block.title} onChange={(event) => updateBlock(block.id, 'title', event.target.value)} placeholder={block.type === 'LINK' ? 'Nome do material' : 'Ex.: Estrutura'} /></div>
              <div className="field"><label htmlFor={`block-content-${block.id}`}>{block.type === 'LINK' ? 'URL' : 'Conteúdo'}</label><textarea id={`block-content-${block.id}`} value={block.content} onChange={(event) => updateBlock(block.id, 'content', event.target.value)} placeholder={block.type === 'LINK' ? 'https://…' : 'Escreva a explicação, exemplos ou anotações…'} required /></div>
            </section>
          ))}
        </div>

        <div className="add-block-row">
          <span>Adicionar:</span>
          {blockOptions.map((option) => <button type="button" className="add-block-button" key={option.type} onClick={() => setBlocks((current) => [...current, newBlock(option.type)])}><Plus size={15} />{option.label}</button>)}
        </div>

        <div className="mobile-save"><button className="button button--primary button--with-icon" disabled={saving}><Save size={18} />{saving ? 'Salvando…' : 'Salvar aula'}</button></div>
      </form>
    </div>
  )
}
