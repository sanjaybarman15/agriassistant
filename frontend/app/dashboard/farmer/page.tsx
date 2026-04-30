'use client';

import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/store/use-auth-store';
import { FarmerOnboarding } from '@/components/dashboard/farmer-onboarding';
import { Loader2 } from 'lucide-react';
import { useQuery, useQueryClient } from '@tanstack/react-query';

export default function FarmerDashboard() {
  const { user, role } = useAuthStore();
  const queryClient = useQueryClient();

  // Unified fetching using React Query
  const { data: farmer, isLoading, refetch } = useQuery({
    queryKey: ['farmer_profile', user?.id],
    queryFn: async () => {
      if (!user || role !== 'farmer') return null;
      const { data, error } = await supabase
        .from('farmers')
        .select('*, districts(name)')
        .eq('profile_id', user.id)
        .single();
      
      if (error) return null;
      return data;
    },
    enabled: !!user && role === 'farmer',
  });

  if (isLoading || !user) {
    return (
      <div className="flex h-[50vh] items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-emerald-500" />
      </div>
    );
  }

  // ONLY show onboarding if the role is 'farmer' AND district_id is missing
  if (role === 'farmer' && !farmer?.district_id) {
    return (
      <div className="max-w-2xl mx-auto pt-10">
        <FarmerOnboarding onComplete={() => refetch()} />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-2">
        <h1 className="text-3xl font-bold tracking-tight">Farmer Dashboard</h1>
        <div className="flex items-center gap-2 text-zinc-400">
          <span>{farmer.village}</span>
          <span className="h-1 w-1 rounded-full bg-zinc-600" />
          <span>{farmer.districts?.name}</span>
        </div>
      </div>
      
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <div className="rounded-xl border border-zinc-800 bg-zinc-900/50 p-6">
          <h3 className="font-semibold text-emerald-500">My Fields</h3>
          <p className="text-2xl font-bold">0</p>
        </div>
        <div className="rounded-xl border border-zinc-800 bg-zinc-900/50 p-6">
          <h3 className="font-semibold text-emerald-500">Recommendations</h3>
          <p className="text-2xl font-bold">0</p>
        </div>
        <div className="rounded-xl border border-zinc-800 bg-zinc-900/50 p-6">
          <h3 className="font-semibold text-emerald-500">Active Alerts</h3>
          <p className="text-2xl font-bold">0</p>
        </div>
        <div className="rounded-xl border border-zinc-800 bg-zinc-900/50 p-6">
          <h3 className="font-semibold text-emerald-500">Soil Health</h3>
          <p className="text-2xl font-bold">N/A</p>
        </div>
      </div>
    </div>
  );
}
