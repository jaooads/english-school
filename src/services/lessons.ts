import { supabase } from '../lib/supabase'
import type { Lesson, LessonDetail } from '../types/domain'

export async function listLessons() {
  const { data, error } = await supabase
    .from('lessons')
    .select('*')
    .order('lesson_date', { ascending: false })
    .order('created_at', { ascending: false })

  if (error) throw new Error('Não foi possível carregar as aulas.')
  return (data ?? []) as Lesson[]
}

export async function getLesson(id: string) {
  const { data, error } = await supabase
    .from('lessons')
    .select(`
      *,
      lesson_blocks (*),
      exercises (*, questions (*, answers (*)))
    `)
    .eq('id', id)
    .single()

  if (error) throw new Error(error.code === 'PGRST116' ? 'Esta aula não foi encontrada.' : 'Não foi possível carregar a aula.')

  const lesson = data as unknown as LessonDetail
  lesson.lesson_blocks.sort((a, b) => a.position - b.position)
  lesson.exercises.sort((a, b) => a.position - b.position)
  lesson.exercises.forEach((exercise) => exercise.questions.sort((a, b) => a.position - b.position))
  return lesson
}

export async function deleteLesson(id: string) {
  const { error } = await supabase.from('lessons').delete().eq('id', id)
  if (error) throw new Error('Não foi possível excluir a aula.')
}
