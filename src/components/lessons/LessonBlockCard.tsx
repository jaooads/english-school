import { BookOpenText, ExternalLink, FileText, Image as ImageIcon, Languages, Lightbulb, List, Table2, Text } from 'lucide-react'
import { parseLessonTable } from '../../lib/lessonTable'
import type { LessonBlock, LessonBlockType } from '../../types/domain'

const blockMeta: Record<LessonBlockType, { label: string; icon: typeof Text }> = {
  TEXT: { label: 'Anotações', icon: Text },
  GRAMMAR: { label: 'Grammar', icon: BookOpenText },
  VOCABULARY: { label: 'Vocabulary', icon: Languages },
  EXAMPLE: { label: 'Examples', icon: Lightbulb },
  LINK: { label: 'Link', icon: ExternalLink },
  IMAGE: { label: 'Material visual', icon: ImageIcon },
  TABLE: { label: 'Study table', icon: Table2 },
}

function isSafeExternalUrl(value: string) {
  try {
    const url = new URL(value)
    return url.protocol === 'http:' || url.protocol === 'https:'
  } catch {
    return false
  }
}

export function getLessonBlockLabel(type: LessonBlockType) {
  return blockMeta[type].label
}

function DidacticText({ content }: { content: string }) {
  const lines = content.split('\n')

  return (
    <div className="lesson-block__content">
      {lines.map((line, index) => {
        const emphasized = /^(regra|estrutura|importante|atenção|remember|resumo|dica)\s*:?/i.test(line.trim())
        return line.trim() ? (
          <p key={`${index}-${line.slice(0, 12)}`} className={emphasized ? 'lesson-block__highlight' : undefined}>{line}</p>
        ) : <span key={index} className="lesson-block__space" aria-hidden="true" />
      })}
    </div>
  )
}

export function LessonBlockCard({ block, step }: { block: LessonBlock; step: number }) {
  const meta = blockMeta[block.type]
  const Icon = meta.icon
  const isSourceNote = block.title?.toLocaleLowerCase('pt-BR').startsWith('identifica')
  const table = block.type === 'TABLE' ? parseLessonTable(block.content) : null

  if (isSourceNote) {
    return (
      <aside id={`block-${block.id}`} className="source-note">
        <FileText size={16} />
        <span><strong>Registro original do caderno</strong>{block.content}</span>
      </aside>
    )
  }

  return (
    <section id={`block-${block.id}`} className={`lesson-block lesson-block--${block.type.toLowerCase()}`}>
      <div className="lesson-block__topline">
        <div className="lesson-block__label"><Icon size={16} /> {meta.label}</div>
        <span className="lesson-block__step">Etapa {String(step).padStart(2, '0')}</span>
      </div>
      {block.title && <h2>{block.title}</h2>}
      {block.type === 'TABLE' && table ? (
        <div className="lesson-table-wrap">
          <table className="lesson-table">
            <thead><tr>{table.headers.map((header, index) => <th key={index}>{header}</th>)}</tr></thead>
            <tbody>{table.rows.map((row, rowIndex) => <tr key={rowIndex}>{row.map((cell, cellIndex) => <td key={cellIndex}>{cell || '—'}</td>)}</tr>)}</tbody>
          </table>
        </div>
      ) : block.type === 'IMAGE' ? (
        <img
          className="lesson-block__image"
          src={isSafeExternalUrl(block.content) ? block.content : `${import.meta.env.BASE_URL}notebook-media/${encodeURIComponent(block.content)}`}
          alt={block.title ?? 'Material visual da aula'}
          loading="lazy"
        />
      ) : block.type === 'LINK' && isSafeExternalUrl(block.content) ? (
        <a href={block.content} target="_blank" rel="noreferrer" className="external-link">
          <span>Abrir material externo</span><ExternalLink size={17} />
        </a>
      ) : (
        <DidacticText content={block.content} />
      )}
    </section>
  )
}

export function LessonSectionMarker({ homework = false }: { homework?: boolean }) {
  return <span className={`section-marker ${homework ? 'section-marker--homework' : ''}`}><List size={16} />{homework ? 'Homework' : 'Exercises'}</span>
}
