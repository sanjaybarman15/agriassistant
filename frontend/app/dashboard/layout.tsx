'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/store/use-auth-store';
import { Button } from '@/components/ui/button';
import { LogOut, User, Leaf } from 'lucide-react';

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { user, profile, isLoading, signOut } = useAuthStore();
  const router = useRouter();

  useEffect(() => {
    if (!isLoading && !user) {
      router.push('/login');
    }
  }, [user, isLoading, router]);

  if (isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-zinc-950 text-emerald-500">
        <Leaf className="h-8 w-8 animate-pulse" />
      </div>
    );
  }

  if (!user) return null;

  return (
    <div className="min-h-screen bg-zinc-950 text-zinc-100">
      {/* Sidebar / Header */}
      <header className="sticky top-0 z-40 border-b border-zinc-800 bg-zinc-950/80 backdrop-blur-md">
        <div className="container mx-auto flex h-16 items-center justify-between px-4">
          <div className="flex items-center gap-2">
            <Leaf className="h-6 w-6 text-emerald-500" />
            <span className="text-xl font-bold tracking-tight">AgriAssistant</span>
          </div>
          
          <div className="flex items-center gap-4">
            <div className="hidden items-center gap-2 md:flex">
              <div className="text-right">
                <p className="text-sm font-medium">{profile?.full_name}</p>
                <p className="text-xs text-zinc-500 capitalize">{profile?.role?.replace('_', ' ')}</p>
              </div>
              <div className="h-8 w-8 rounded-full bg-emerald-500/20 flex items-center justify-center border border-emerald-500/30">
                <User className="h-4 w-4 text-emerald-500" />
              </div>
            </div>
            <Button 
              variant="ghost" 
              size="icon" 
              onClick={() => signOut().then(() => router.push('/login'))}
              className="text-zinc-400 hover:text-white hover:bg-zinc-800"
            >
              <LogOut className="h-5 w-5" />
            </Button>
          </div>
        </div>
      </header>

      <main className="container mx-auto p-4 md:p-8">
        {children}
      </main>
    </div>
  );
}
