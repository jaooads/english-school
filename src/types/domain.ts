export type AppRole = 'TEACHER' | 'STUDENT'
export type LessonBlockType = 'TEXT' | 'GRAMMAR' | 'VOCABULARY' | 'EXAMPLE' | 'LINK' | 'IMAGE'
export type ExerciseType = 'TEXT_INPUT' | 'TEXTAREA' | 'MULTIPLE_CHOICE'
export type AnswerStatus = 'PENDING' | 'CORRECT' | 'INCORRECT'

export interface Profile {
  id: string
  name: string
  role: AppRole
}

export interface Lesson {
  id: string
  title: string
  lesson_date: string
  created_by: string
  created_at: string
  updated_at: string
}

export interface LessonBlock {
  id: string
  lesson_id: string
  type: LessonBlockType
  title: string | null
  content: string
  position: number
}

export interface Exercise {
  id: string
  lesson_id: string
  title: string
  instructions: string | null
  type: ExerciseType
  is_homework: boolean
  position: number
  created_at: string
}

export interface Question {
  id: string
  exercise_id: string
  question: string
  position: number
}

export interface Answer {
  id: string
  question_id: string
  student_id: string
  answer: string
  status: AnswerStatus
  corrected_answer: string | null
  teacher_feedback: string | null
  created_at: string
  updated_at: string
}

export interface ExerciseWithQuestions extends Exercise {
  questions: Array<Question & { answers: Answer[] }>
}

export interface LessonDetail extends Lesson {
  lesson_blocks: LessonBlock[]
  exercises: ExerciseWithQuestions[]
}
