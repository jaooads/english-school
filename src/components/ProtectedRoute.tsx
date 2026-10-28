import { Navigate, Outlet, useLocation } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'
import { FullPageState } from './FullPageState'

export function ProtectedRoute() {
  const { session, profile, loading, profileError } = useAuth()
  const location = useLocation()

  if (loading) return <FullPageState />
  if (!session) return <Navigate to="/login" replace state={{ from: location }} />
  if (profileError || !profile) {
    return (
      <FullPageState
        error
        title="Perfil não encontrado"
        message={profileError ?? 'Peça para configurar seu perfil no Supabase.'}
      />
    )
  }

  return <Outlet />
}
