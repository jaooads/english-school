import { Navigate, Route, Routes } from 'react-router-dom'
import { FullPageState } from './components/FullPageState'
import { ProtectedRoute } from './components/ProtectedRoute'
import { AppLayout } from './components/layout/AppLayout'
import { AuthProvider } from './contexts/AuthContext'
import { supabaseConfigured } from './lib/supabase'
import { HomePage } from './pages/HomePage'
import { LessonsPage } from './pages/LessonsPage'
import { LessonPage } from './pages/LessonPage'
import { LessonEditorPage } from './pages/LessonEditorPage'
import { ExerciseEditorPage } from './pages/ExerciseEditorPage'
import { ExercisesPage } from './pages/ExercisesPage'
import { LoginPage } from './pages/LoginPage'
import { ProfilePage } from './pages/ProfilePage'

function App() {
  if (!supabaseConfigured) {
    return (
      <FullPageState
        error
        title="Configure o Supabase"
        message="Copie .env.example para .env e preencha a URL e a chave pública do projeto."
      />
    )
  }

  return (
    <AuthProvider>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route element={<ProtectedRoute />}>
          <Route element={<AppLayout />}>
            <Route index element={<HomePage />} />
            <Route path="aulas" element={<LessonsPage />} />
            <Route path="aulas/:lessonId" element={<LessonPage />} />
            <Route path="aulas/nova" element={<LessonEditorPage />} />
            <Route path="aulas/:lessonId/editar" element={<LessonEditorPage />} />
            <Route path="aulas/:lessonId/exercicios/novo" element={<ExerciseEditorPage />} />
            <Route path="aulas/:lessonId/exercicios/:exerciseId/editar" element={<ExerciseEditorPage />} />
            <Route path="exercicios" element={<ExercisesPage />} />
            <Route path="perfil" element={<ProfilePage />} />
          </Route>
        </Route>
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </AuthProvider>
  )
}

export default App
