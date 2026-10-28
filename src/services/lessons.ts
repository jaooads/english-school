import { supabase } from '../lib/supabase'
import type { Lesson } from '../types/domain'

export async function listLessons() {
  const { data, error } = await supabase
    .from('lessons')
    .select('*')
    .order('lesson_date', { ascending: false })
    .order('created_at', { ascending: false })

  if (error) throw new Error('Não foi possível carregar as aulas.')
  return (data ?? []) as Lesson[]
}
