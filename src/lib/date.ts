const dateFormatter = new Intl.DateTimeFormat('pt-BR', {
  day: '2-digit',
  month: '2-digit',
  year: 'numeric',
})

const monthFormatter = new Intl.DateTimeFormat('pt-BR', {
  month: 'long',
  year: 'numeric',
})

function safeDate(date: string) {
  return new Date(`${date}T12:00:00`)
}

export function formatDate(date: string) {
  return dateFormatter.format(safeDate(date))
}

export function formatMonth(date: string) {
  return monthFormatter.format(safeDate(date)).toLocaleUpperCase('pt-BR')
}

export function todayInputValue() {
  const today = new Date()
  const offset = today.getTimezoneOffset()
  return new Date(today.getTime() - offset * 60_000).toISOString().slice(0, 10)
}
