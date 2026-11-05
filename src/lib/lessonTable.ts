export interface LessonTableData {
  headers: string[]
  rows: string[][]
}

export function createLessonTable(): LessonTableData {
  return {
    headers: ['Verb', 'Simple Past', 'Meaning'],
    rows: [
      ['', '', ''],
      ['', '', ''],
      ['', '', ''],
    ],
  }
}

export function parseLessonTable(content: string): LessonTableData | null {
  try {
    const parsed = JSON.parse(content) as Partial<LessonTableData>
    if (!Array.isArray(parsed.headers) || parsed.headers.length < 2 || !parsed.headers.every((header) => typeof header === 'string')) return null
    if (!Array.isArray(parsed.rows) || !parsed.rows.every((row) => Array.isArray(row) && row.every((cell) => typeof cell === 'string'))) return null
    return {
      headers: parsed.headers,
      rows: parsed.rows.map((row) => parsed.headers!.map((_header, index) => row[index] ?? '')),
    }
  } catch {
    return null
  }
}

export function serializeLessonTable(table: LessonTableData) {
  return JSON.stringify(table)
}
