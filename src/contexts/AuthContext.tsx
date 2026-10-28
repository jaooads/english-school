import type { Session } from '@supabase/supabase-js'
import { createContext, useContext, useEffect, useMemo, useState, type ReactNode } from 'react'
import { supabase, supabaseConfigured } from '../lib/supabase'
import type { Profile } from '../types/domain'

interface AuthContextValue {
  session: Session | null
  profile: Profile | null
  loading: boolean
  profileError: string | null
  signIn: (email: string, password: string) => Promise<void>
  signOut: () => Promise<void>
}

const AuthContext = createContext<AuthContextValue | null>(null)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<Session | null>(null)
  const [profile, setProfile] = useState<Profile | null>(null)
  const [loading, setLoading] = useState(supabaseConfigured)
  const [profileError, setProfileError] = useState<string | null>(null)

  useEffect(() => {
    if (!supabaseConfigured) return

    let active = true

    async function loadProfile(nextSession: Session | null) {
      if (!active) return
      setSession(nextSession)

      if (!nextSession) {
        setProfile(null)
        setProfileError(null)
        setLoading(false)
        return
      }

      const { data, error } = await supabase
        .from('profiles')
        .select('id, name, role')
        .eq('id', nextSession.user.id)
        .single()

      if (!active) return

      if (error) {
        setProfile(null)
        setProfileError('Não foi possível carregar o perfil deste usuário.')
      } else {
        setProfile(data as Profile)
        setProfileError(null)
      }
      setLoading(false)
    }

    void supabase.auth.getSession().then(({ data }) => loadProfile(data.session))

    const { data: listener } = supabase.auth.onAuthStateChange((_event, nextSession) => {
      window.setTimeout(() => void loadProfile(nextSession), 0)
    })

    return () => {
      active = false
      listener.subscription.unsubscribe()
    }
  }, [])

  async function signIn(email: string, password: string) {
    setLoading(true)
    const { error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) {
      setLoading(false)
      throw new Error('E-mail ou senha incorretos.')
    }
  }

  async function signOut() {
    const { error } = await supabase.auth.signOut()
    if (error) throw new Error('Não foi possível sair. Tente novamente.')
  }

  const value = useMemo(
    () => ({ session, profile, loading, profileError, signIn, signOut }),
    [session, profile, loading, profileError],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const value = useContext(AuthContext)
  if (!value) throw new Error('useAuth must be used inside AuthProvider')
  return value
}
