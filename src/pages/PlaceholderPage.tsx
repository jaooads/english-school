import { Construction } from 'lucide-react'
import { PageHeader } from '../components/PageHeader'

export function PlaceholderPage({ title }: { title: string }) {
  return (
    <div className="page">
      <PageHeader title={title} />
      <div className="empty-state"><Construction size={28} /><h2>Em construção</h2><p>Esta área será a próxima etapa do caderno.</p></div>
    </div>
  )
}
