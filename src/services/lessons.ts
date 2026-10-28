import { supabase } from '../lib/supabase'
import type { ExerciseType, Lesson, LessonBlockType, LessonDetail } from '../types/domain'

interface SaveLessonInput {
  id?: string
  title: string
  lessonDate: string
  createdBy: string
  blocks: Array<{ id: string; persisted: boolean; type: LessonBlockType; title: string; content: string }>
  removedBlockIds: string[]
}

interface SaveExerciseInput {
  id?: string
  lessonId: string
  title: string
  instructions: string
  type: ExerciseType
  isHomework: boolean
  position: number
  questions: Array<{ id: string; persisted: boolean; question: string }>
  removedQuestionIds: string[]
}

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

export async function saveLesson(input: SaveLessonInput) {
  let lessonId = input.id

  if (lessonId) {
    const { error } = await supabase.from('lessons').update({ title: input.title, lesson_date: input.lessonDate }).eq('id', lessonId)
    if (error) throw new Error('Não foi possível atualizar os dados da aula.')
  } else {
    const { data, error } = await supabase
      .from('lessons')
      .insert({ title: input.title, lesson_date: input.lessonDate, created_by: input.createdBy })
      .select('id')
      .single()
    if (error || !data) throw new Error('Não foi possível criar a aula.')
    lessonId = data.id as string
  }

  if (input.removedBlockIds.length > 0) {
    const { error } = await supabase.from('lesson_blocks').delete().in('id', input.removedBlockIds)
    if (error) throw new Error('A aula foi salva, mas não foi possível remover um bloco.')
  }

  const existingBlocks = input.blocks.filter((block) => block.persisted)
  const newBlocks = input.blocks.filter((block) => !block.persisted)

  for (const block of existingBlocks) {
    const { error } = await supabase.from('lesson_blocks').update({
      type: block.type,
      title: block.title.trim() || null,
      content: block.content.trim(),
      position: input.blocks.indexOf(block),
    }).eq('id', block.id)
    if (error) throw new Error('A aula foi salva, mas um bloco não pôde ser atualizado.')
  }

  if (newBlocks.length > 0) {
    const { error } = await supabase.from('lesson_blocks').insert(newBlocks.map((block) => ({
      lesson_id: lessonId,
      type: block.type,
      title: block.title.trim() || null,
      content: block.content.trim(),
      position: input.blocks.indexOf(block),
    })))
    if (error) throw new Error('A aula foi salva, mas um bloco não pôde ser adicionado.')
  }

  return lessonId
}

export async function saveExercise(input: SaveExerciseInput) {
  let exerciseId = input.id
  const exerciseValues = {
    title: input.title,
    instructions: input.instructions || null,
    type: input.type,
    is_homework: input.isHomework,
    position: input.position,
  }

  if (exerciseId) {
    const { error } = await supabase.from('exercises').update(exerciseValues).eq('id', exerciseId)
    if (error) throw new Error('Não foi possível atualizar a atividade.')
  } else {
    const { data, error } = await supabase
      .from('exercises')
      .insert({ ...exerciseValues, lesson_id: input.lessonId })
      .select('id')
      .single()
    if (error || !data) throw new Error('Não foi possível criar a atividade.')
    exerciseId = data.id as string
  }

  if (input.removedQuestionIds.length > 0) {
    const { error } = await supabase.from('questions').delete().in('id', input.removedQuestionIds)
    if (error) throw new Error('A atividade foi salva, mas não foi possível remover uma questão.')
  }

  for (const question of input.questions.filter((item) => item.persisted)) {
    const { error } = await supabase.from('questions').update({
      question: question.question.trim(),
      position: input.questions.indexOf(question),
    }).eq('id', question.id)
    if (error) throw new Error('A atividade foi salva, mas uma questão não pôde ser atualizada.')
  }

  const newQuestions = input.questions.filter((item) => !item.persisted)
  if (newQuestions.length > 0) {
    const { error } = await supabase.from('questions').insert(newQuestions.map((question) => ({
      exercise_id: exerciseId,
      question: question.question.trim(),
      position: input.questions.indexOf(question),
    })))
    if (error) throw new Error('A atividade foi salva, mas uma questão não pôde ser adicionada.')
  }

  return exerciseId
}

export async function deleteExercise(id: string) {
  const { error } = await supabase.from('exercises').delete().eq('id', id)
  if (error) throw new Error('Não foi possível excluir a atividade.')
}
