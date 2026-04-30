'use client';

import { useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/store/use-auth-store';

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const { setUser, fetchProfile, setProfile } = useAuthStore();

  useEffect(() => {
    // Check active session on mount
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session?.user) {
        setUser(session.user);
        fetchProfile(session.user.id);
      } else {
        useAuthStore.setState({ isLoading: false });
      }
    });

    // Listen for auth state changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange((event, session) => {
      if (session?.user) {
        setUser(session.user);
        fetchProfile(session.user.id);
      } else {
        setUser(null);
        setProfile(null);
        useAuthStore.setState({ isLoading: false });
      }
    });

    return () => {
      subscription.unsubscribe();
    };
  }, [setUser, fetchProfile, setProfile]);

  return <>{children}</>;
}
