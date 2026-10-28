import { BookOpenText, ExternalLink, Image as ImageIcon, Languages, Lightbulb, List, Text } from 'lucide-react'
import type { LessonBlock, LessonBlockType } from '../../types/domain'

const blockMeta: Record<LessonBlockType, { label: string; icon: typeof Text }> = {
  TEXT: { label: 'Anotações', icon: Text },
  GRAMMAR: { label: 'Grammar', icon: BookOpenText },
  VOCABULARY: { label: 'Vocabulary', icon: Languages },
  EXAMPLE: { label: 'Examples', icon: Lightbulb },
  LINK: { label: 'Link', icon: ExternalLink },
  IMAGE: { label: 'Material visual', icon: ImageIcon },
}

function isSafeExternalUrl(value: string) {
  try {
    const url = new URL(value)
    return url.protocol === 'http:' || url.protocol === 'https:'
  } catch {
    return false
  }
}

export function LessonBlockCard({ block }: { block: LessonBlock }) {
  const meta = blockMeta[block.type]
  const Icon = meta.icon

  return (
    <section className={`lesson-block lesson-block--${block.type.toLowerCase()}`}>
      <div className="lesson-block__label"><Icon size={16} /> {meta.label}</div>
      {block.title && <h2>{block.title}</h2>}
      {block.type === 'IMAGE' ? (
        <img
          className="lesson-block__image"
          src={isSafeExternalUrl(block.content) ? block.content : `${import.meta.env.BASE_URL}notebook-media/${encodeURIComponent(block.content)}`}
          alt={block.title ?? 'Material visual da aula'}
          loading="lazy"
        />
      ) : block.type === 'LINK' && isSafeExternalUrl(block.content) ? (
        <a href={block.content} target="_blank" rel="noreferrer" className="external-link">
          <span>{block.title ?? block.content}</span><ExternalLink size={17} />
        </a>
      ) : (
        <div className="lesson-block__content">{block.content}</div>
      )}
    </section>
  )
}

export function LessonSectionMarker({ homework = false }: { homework?: boolean }) {
  return <span className={`section-marker ${homework ? 'section-marker--homework' : ''}`}><List size={16} />{homework ? 'Homework' : 'Exercises'}</span>
}
