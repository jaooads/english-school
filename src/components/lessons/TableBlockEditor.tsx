import { Plus, Trash2 } from 'lucide-react'
import { createLessonTable, parseLessonTable, serializeLessonTable, type LessonTableData } from '../../lib/lessonTable'

interface TableBlockEditorProps {
  value: string
  onChange: (value: string) => void
}

export function TableBlockEditor({ value, onChange }: TableBlockEditorProps) {
  const table = parseLessonTable(value) ?? createLessonTable()

  function update(next: LessonTableData) {
    onChange(serializeLessonTable(next))
  }

  function updateHeader(index: number, header: string) {
    update({ ...table, headers: table.headers.map((current, currentIndex) => currentIndex === index ? header : current) })
  }

  function updateCell(rowIndex: number, columnIndex: number, cell: string) {
    update({
      ...table,
      rows: table.rows.map((row, currentRow) => currentRow === rowIndex
        ? row.map((current, currentColumn) => currentColumn === columnIndex ? cell : current)
        : row),
    })
  }

  function addColumn() {
    if (table.headers.length >= 6) return
    update({ headers: [...table.headers, `Column ${table.headers.length + 1}`], rows: table.rows.map((row) => [...row, '']) })
  }

  function removeColumn(index: number) {
    if (table.headers.length <= 2) return
    update({ headers: table.headers.filter((_header, current) => current !== index), rows: table.rows.map((row) => row.filter((_cell, current) => current !== index)) })
  }

  return (
    <div className="table-block-editor">
      <div className="table-block-editor__scroll">
        <table>
          <thead><tr>{table.headers.map((header, index) => <th key={index}><input value={header} onChange={(event) => updateHeader(index, event.target.value)} aria-label={`Título da coluna ${index + 1}`} /><button type="button" onClick={() => removeColumn(index)} disabled={table.headers.length <= 2} aria-label={`Remover coluna ${index + 1}`}><Trash2 size={14} /></button></th>)}</tr></thead>
          <tbody>{table.rows.map((row, rowIndex) => <tr key={rowIndex}>{row.map((cell, columnIndex) => <td key={columnIndex}><input value={cell} onChange={(event) => updateCell(rowIndex, columnIndex, event.target.value)} aria-label={`Linha ${rowIndex + 1}, coluna ${columnIndex + 1}`} /></td>)}</tr>)}</tbody>
        </table>
      </div>
      <div className="table-block-editor__actions">
        <button type="button" className="add-block-button" onClick={() => update({ ...table, rows: [...table.rows, table.headers.map(() => '')] })}><Plus size={15} /> Adicionar linha</button>
        <button type="button" className="add-block-button" onClick={addColumn} disabled={table.headers.length >= 6}><Plus size={15} /> Adicionar coluna</button>
        <button type="button" className="add-block-button add-block-button--danger" onClick={() => update({ ...table, rows: table.rows.slice(0, -1) })} disabled={table.rows.length === 0}><Trash2 size={15} /> Remover última linha</button>
      </div>
    </div>
  )
}
