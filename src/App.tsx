import { Navigate, Route, Routes } from 'react-router-dom'
import { FullPageState } from './components/FullPageState'
import { ProtectedRoute } from './components/ProtectedRoute'
import { AuthProvider, useAuth } from './contexts/AuthContext'
import { supabaseConfigured } from './lib/supabase'
import { LoginPage } from './pages/LoginPage'

function NotebookPlaceholder() {
  const { profile } = useAuth()
  return (
    <main className="welcome">
      <span className="eyebrow">English School</span>
      <h1>Olá, {profile?.name}.</h1>
      <p>Seu caderno está pronto para receber as aulas.</p>
    </main>
  )
}

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
          <Route index element={<NotebookPlaceholder />} />
        </Route>
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </AuthProvider>
  )
}

export default App
