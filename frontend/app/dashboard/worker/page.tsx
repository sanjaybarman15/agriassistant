'use client';

import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/store/use-auth-store';
import { 
  Users, 
  MapPin, 
  Search, 
  Loader2, 
  ChevronRight, 
  PlusCircle, 
  FlaskConical,
  ClipboardCheck,
  Signal,
  LayoutDashboard,
  AlertCircle
} from 'lucide-react';
import { useQuery } from '@tanstack/react-query';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { ScrollArea } from '@/components/ui/scroll-area';
import { motion } from 'framer-motion';

export default function FieldWorkerDashboard() {
  const { user, role } = useAuthStore();

  // 1. Fetch Field Worker Profile
  const { data: worker, isLoading: isWorkerLoading, error: workerError } = useQuery({
    queryKey: ['worker_profile', user?.id],
    queryFn: async () => {
      console.log("DEBUG: Fetching worker for profile_id:", user?.id);
      if (!user?.id) return null;
      
      const { data, error } = await supabase
        .from('field_workers')
        .select('*, districts(name)')
        .eq('profile_id', user.id)
        .maybeSingle(); // Using maybeSingle to avoid 406 errors
      
      if (error) {
        console.error("DEBUG: Worker fetch error:", error);
        throw error;
      }
      console.log("DEBUG: Worker found:", data);
      return data;
    },
    enabled: !!user?.id,
  });

  // 2. Fetch Assigned Farmers
  const { data: farmers = [], isLoading: isFarmersLoading, error: farmersError } = useQuery({
    queryKey: ['assigned_farmers', worker?.id],
    queryFn: async () => {
      console.log("DEBUG: Fetching farmers for worker_id:", worker?.id);
      if (!worker?.id) return [];
      
      const { data, error } = await supabase
        .from('farmers')
        .select('*, profiles(full_name)')
        .eq('assigned_field_worker_id', worker.id);
      
      if (error) {
        console.error("DEBUG: Farmers fetch error:", error);
        throw error;
      }
      console.log("DEBUG: Farmers found:", data);
      return data;
    },
    enabled: !!worker?.id,
  });

  if (isWorkerLoading) {
    return (
      <div className="flex h-[50vh] items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-emerald-500" />
      </div>
    );
  }

  // Debug Error State
  if (!worker && !isWorkerLoading) {
    return (
      <div className="p-8 max-w-2xl mx-auto mt-20 rounded-2xl border border-red-500/20 bg-red-500/5 text-center space-y-4">
        <AlertCircle className="h-12 w-12 text-red-500 mx-auto" />
        <h2 className="text-xl font-bold text-white">Worker Profile Not Found</h2>
        <p className="text-zinc-400 text-sm">
          Your profile (ID: <code className="text-emerald-500">{user?.id}</code>) is not yet registered in the <code>field_workers</code> table. 
          Please contact your administrator to link your account.
        </p>
        <Button onClick={() => window.location.reload()} variant="outline" className="border-zinc-800">
          Retry Sync
        </Button>
      </div>
    );
  }

  return (
    <div className="space-y-8 p-2">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-4">
        <div className="space-y-1">
          <div className="flex items-center gap-2 text-emerald-500 mb-1">
            <LayoutDashboard className="h-4 w-4" />
            <span className="text-[10px] font-bold uppercase tracking-[0.2em]">Operations Command</span>
          </div>
          <h1 className="text-4xl font-black tracking-tight text-white">Field Worker Dashboard</h1>
          <p className="text-zinc-500 text-sm font-medium">Managing village clusters in <span className="text-zinc-300">{worker?.districts?.name || 'Assam'}</span>.</p>
        </div>
        <Button className="bg-emerald-600 hover:bg-emerald-500 text-white font-bold h-12 px-6 rounded-xl shadow-lg shadow-emerald-900/20 gap-2">
          <PlusCircle className="h-5 w-5" /> Register New Farmer
        </Button>
      </div>

      {/* Premium Stats Grid */}
      <div className="grid gap-4 md:grid-cols-4">
        {[
          { label: 'Assigned Farmers', value: farmers.length, icon: Users, color: 'text-blue-500', bg: 'bg-blue-500/10' },
          { label: 'Pending Soil Tests', value: '12', icon: FlaskConical, color: 'text-emerald-500', bg: 'bg-emerald-500/10' },
          { label: 'Villages Covered', value: [...new Set(farmers.map(f => f.village))].length, icon: MapPin, color: 'text-orange-500', bg: 'bg-orange-500/10' },
          { label: 'Sync Status', value: 'Healthy', icon: Signal, color: 'text-purple-500', bg: 'bg-purple-500/10' },
        ].map((stat, i) => (
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.1 }}
            key={stat.label} 
            className="rounded-2xl border border-zinc-800 bg-zinc-900/40 p-5 space-y-3 hover:bg-zinc-900/60 transition-all group"
          >
            <div className="flex items-center justify-between">
              <p className="text-[10px] font-bold uppercase tracking-widest text-zinc-500">{stat.label}</p>
              <div className={`p-2 rounded-lg ${stat.bg}`}>
                <stat.icon className={`h-4 w-4 ${stat.color}`} />
              </div>
            </div>
            <p className="text-3xl font-black text-white">{stat.value}</p>
          </motion.div>
        ))}
      </div>

      {/* Main Content Area */}
      <div className="grid gap-8 lg:grid-cols-3">
        {/* Left Column: Farmer Directory */}
        <div className="lg:col-span-2 space-y-4">
          <div className="flex items-center justify-between mb-2">
            <h2 className="text-xl font-bold flex items-center gap-2">
              Farmer Directory
              <span className="text-[9px] bg-zinc-800 text-zinc-500 px-2 py-0.5 rounded-full uppercase font-black">Active Database</span>
            </h2>
            <div className="relative w-64">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-zinc-600" />
              <Input 
                placeholder="Search by name or village..." 
                className="pl-10 bg-zinc-900/50 border-zinc-800 h-10 rounded-xl text-sm focus:ring-emerald-500"
              />
            </div>
          </div>

          <div className="rounded-2xl border border-zinc-800 bg-zinc-900/20 overflow-hidden backdrop-blur-sm">
            <ScrollArea className="h-[500px]">
              {isFarmersLoading ? (
                <div className="flex flex-col items-center justify-center py-20 gap-4">
                  <Loader2 className="h-8 w-8 animate-spin text-emerald-500" />
                  <p className="text-xs text-zinc-600 font-bold uppercase tracking-widest">Loading Records...</p>
                </div>
              ) : farmers.length > 0 ? (
                <div className="divide-y divide-zinc-900">
                  {farmers.map((farmer, idx) => (
                    <motion.div 
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 1 }}
                      transition={{ delay: idx * 0.05 }}
                      key={farmer.id} 
                      className="flex items-center justify-between p-4 hover:bg-zinc-800/30 transition-all cursor-pointer group"
                    >
                      <div className="flex items-center gap-4">
                        <div className="h-12 w-12 rounded-2xl bg-zinc-900 border border-zinc-800 flex items-center justify-center text-emerald-500 font-black text-lg group-hover:border-emerald-500/50 transition-colors shadow-inner">
                          {farmer.profiles?.full_name?.charAt(0) || 'F'}
                        </div>
                        <div>
                          <p className="font-bold text-white group-hover:text-emerald-400 transition-colors">
                            {farmer.profiles?.full_name || 'Unnamed Farmer'}
                          </p>
                          <div className="flex items-center gap-2 mt-0.5">
                            <span className="flex items-center gap-1 text-[10px] text-zinc-500 font-medium">
                              <MapPin className="h-3 w-3" /> {farmer.village}
                            </span>
                            <span className="h-1 w-1 rounded-full bg-zinc-800" />
                            <span className="text-[10px] text-zinc-500 font-medium uppercase tracking-tighter">
                               Land: {farmer.total_land_bigha || 0} Bigha
                            </span>
                          </div>
                        </div>
                      </div>
                      <Button variant="ghost" size="sm" className="h-9 w-9 rounded-xl border border-zinc-800 hover:bg-emerald-500 hover:text-white transition-all">
                        <ChevronRight className="h-4 w-4" />
                      </Button>
                    </motion.div>
                  ))}
                </div>
              ) : (
                <div className="flex flex-col items-center justify-center py-32 text-center">
                  <Users className="h-12 w-12 text-zinc-800 mb-4" />
                  <h3 className="text-lg font-bold text-zinc-500">No Farmers Found</h3>
                  <p className="text-xs text-zinc-600 max-w-[200px] mt-1">You haven't been assigned any farmers in this district yet.</p>
                </div>
              )}
            </ScrollArea>
          </div>
        </div>

        {/* Right Column */}
        <div className="space-y-6">
          <div className="p-6 rounded-2xl border border-zinc-800 bg-emerald-500/5 space-y-4">
            <h3 className="text-sm font-bold uppercase tracking-widest text-emerald-500 flex items-center gap-2">
              <ClipboardCheck className="h-4 w-4" /> Field Tasks
            </h3>
            <div className="space-y-3">
              {[
                { task: 'Collect sample from Bordoloi Plot', priority: 'High', due: 'Today' },
                { task: 'Verify Jute harvest in Chandrapur', priority: 'Medium', due: 'Tomorrow' },
                { task: 'Update NPK for Farmer Sanjay', priority: 'Urgent', due: 'Now' },
              ].map((t) => (
                <div key={t.task} className="p-3 rounded-xl bg-zinc-950/50 border border-zinc-800 hover:border-emerald-500/30 transition-colors group">
                  <p className="text-xs font-bold text-zinc-200">{t.task}</p>
                  <div className="flex items-center justify-between mt-2">
                    <span className={`text-[9px] font-black uppercase px-2 py-0.5 rounded ${
                      t.priority === 'Urgent' ? 'bg-red-500 text-white' : 'bg-zinc-800 text-zinc-400'
                    }`}>{t.priority}</span>
                    <span className="text-[9px] text-zinc-500 font-bold">{t.due}</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
