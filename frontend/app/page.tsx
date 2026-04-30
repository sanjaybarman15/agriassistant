'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/store/use-auth-store';
import { Leaf } from 'lucide-react';

export default function RootPage() {
  const { user, role, isLoading } = useAuthStore();
  const router = useRouter();

  useEffect(() => {
    if (isLoading) return;

    if (!user) {
      router.push('/login');
    } else if (role) {
      // Role-based redirection
      console.log('Redirecting based on role:', role);
      switch (role) {
        case 'farmer':
          router.push('/dashboard/farmer');
          break;
        case 'field_worker':
          router.push('/dashboard/field-worker');
          break;
        case 'district_officer':
          router.push('/dashboard/district-officer');
          break;
        case 'super_admin':
          router.push('/dashboard/super-admin');
          break;
        default:
          console.error('Unknown role:', role);
          break;
      }
    } else {
      // User is logged in but role is missing - might be a sync delay
      console.log('User logged in but role missing, retrying fetch...');
      useAuthStore.getState().fetchProfile(user.id);
    }
  }, [user, role, isLoading, router]);

  return (
    <div className="flex min-h-screen items-center justify-center bg-zinc-950 text-emerald-500">
      <div className="flex flex-col items-center gap-4">
        <Leaf className="h-12 w-12 animate-pulse" />
        <h1 className="text-2xl font-bold tracking-tight text-white">AgriAssistant</h1>
        <p className="text-zinc-500">Initializing your experience...</p>
      </div>
    </div>
  );
}
