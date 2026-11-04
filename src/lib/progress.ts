import type { ExerciseWithQuestions } from '../types/domain'

export function getExerciseProgress(exercise: ExerciseWithQuestions) {
  const answers = exercise.questions.flatMap((question) => question.answers)
  const answered = exercise.questions.filter((question) => question.answers.length > 0).length
  const corrected = answers.filter((answer) => answer.status !== 'PENDING').length
  const total = exercise.questions.length
  const complete = total > 0 && answered === total && corrected === total

  return {
    answered,
    corrected,
    total,
    complete,
    percentage: total > 0 ? Math.round((answered / total) * 100) : 0,
    pendingCorrection: answers.some((answer) => answer.status === 'PENDING'),
  }
}
