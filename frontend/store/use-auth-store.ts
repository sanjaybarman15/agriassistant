import { create } from 'zustand';
import { User } from '@supabase/supabase-js';
import { supabase } from '@/lib/supabase';

export type UserRole = 'farmer' | 'field_worker' | 'district_officer' | 'super_admin';

interface Profile {
  id: string;
  full_name: string;
  role: UserRole;
  avatar_url?: string;
  preferred_language: string;
}

interface AuthState {
  user: User | null;
  profile: Profile | null;
  role: UserRole | null;
  isLoading: boolean;
  setUser: (user: User | null) => void;
  setProfile: (profile: Profile | null) => void;
  fetchProfile: (userId: string) => Promise<void>;
  signOut: () => Promise<void>;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  profile: null,
  role: null,
  isLoading: true,

  setUser: (user) => set({ user }),
  
  setProfile: (profile) => set({ 
    profile, 
    role: profile?.role || null,
    isLoading: false 
  }),

  fetchProfile: async (userId) => {
    set({ isLoading: true });
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .single();

      if (error) throw error;
      
      set({ 
        profile: data as Profile, 
        role: data.role as UserRole,
        isLoading: false 
      });
    } catch (error) {
      console.error('Error fetching profile:', error);
      set({ profile: null, role: null, isLoading: false });
    }
  },

  signOut: async () => {
    await supabase.auth.signOut();
    set({ user: null, profile: null, role: null, isLoading: false });
  },
}));
