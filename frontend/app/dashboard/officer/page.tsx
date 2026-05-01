'use client';

import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/store/use-auth-store';
import { IssueAlertModal } from '@/components/dashboard/issue-alert-modal';
import { 
  Building2, 
  Users, 
  Sprout, 
  AlertTriangle, 
  TrendingUp, 
  BarChart3, 
  Map as MapIcon,
  BellRing,
  Loader2,
  ChevronRight,
  ShieldCheck
} from 'lucide-react';
import { useQuery } from '@tanstack/react-query';
import { Button } from '@/components/ui/button';
import { ScrollArea } from '@/components/ui/scroll-area';
import { motion } from 'framer-motion';

export default function DistrictOfficerDashboard() {
  const { user } = useAuthStore();

  // 1. Fetch Officer Profile & District Info
  const { data: officer, isLoading: isOfficerLoading } = useQuery({
    queryKey: ['officer_profile', user?.id],
    queryFn: async () => {
      if (!user?.id) return null;
      const { data, error } = await supabase
        .from('district_officers')
        .select('*, districts(id, name)')
        .eq('profile_id', user.id)
        .single();
      
      if (error) return null;
      return data;
    },
  });

  // 2. Fetch District Summary (From the View in schema.sql)
  const { data: summary, isLoading: isSummaryLoading } = useQuery({
    queryKey: ['district_summary', officer?.district_id],
    queryFn: async () => {
      if (!officer?.district_id) return null;
      const { data, error } = await supabase
        .from('district_summaries')
        .select('*')
        .eq('district_id', officer.district_id)
        .single();
      
      if (error) return null;
      return data;
    },
    enabled: !!officer?.district_id,
  });

  if (isOfficerLoading) {
    return (
      <div className="flex h-[50vh] items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-blue-500" />
      </div>
    );
  }

  return (
    <div className="space-y-8 p-2">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-4">
        <div className="space-y-1">
          <div className="flex items-center gap-2 text-blue-500 mb-1">
            <Building2 className="h-4 w-4" />
            <span className="text-[10px] font-bold uppercase tracking-[0.2em]">Administrative Control</span>
          </div>
          <h1 className="text-4xl font-black tracking-tight text-white">District Command Center</h1>
          <p className="text-zinc-500 text-sm font-medium">Strategic oversight for <span className="text-zinc-300">{officer?.districts?.name || 'Your District'}</span>, Assam.</p>
        </div>
        <div className="flex gap-3">
          <Button variant="outline" className="border-zinc-800 text-zinc-400 gap-2 h-12 rounded-xl">
            <BarChart3 className="h-4 w-4" /> Export Report
          </Button>
          {officer?.district_id && user?.id && (
            <IssueAlertModal districtId={officer.district_id} userId={user.id} />
          )}
        </div>
      </div>

      {/* Strategic Stats */}
      <div className="grid gap-4 md:grid-cols-4">
        {[
          { label: 'Total Farmers', value: summary?.total_farmers || '0', icon: Users, color: 'text-blue-500', bg: 'bg-blue-500/10' },
          { label: 'Active Workers', value: summary?.total_field_workers || '0', icon: ShieldCheck, color: 'text-emerald-500', bg: 'bg-emerald-500/10' },
          { label: 'Avg Soil pH', value: summary?.avg_ph?.toFixed(1) || 'N/A', icon: Sprout, color: 'text-orange-500', bg: 'bg-orange-500/10' },
          { label: 'Active Alerts', value: '2', icon: AlertTriangle, color: 'text-red-500', bg: 'bg-red-500/10' },
        ].map((stat, i) => (
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.1 }}
            key={stat.label} 
            className="rounded-2xl border border-zinc-800 bg-zinc-900/40 p-5 space-y-3"
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

      {/* Analytical Grid */}
      <div className="grid gap-8 lg:grid-cols-3">
        {/* District Trends */}
        <div className="lg:col-span-2 space-y-4">
          <div className="p-6 rounded-2xl border border-zinc-800 bg-zinc-900/20 h-[400px] flex flex-col items-center justify-center text-center space-y-4">
            <div className="h-16 w-16 rounded-full bg-zinc-800 flex items-center justify-center">
              <TrendingUp className="h-8 w-8 text-zinc-600" />
            </div>
            <div>
              <h3 className="text-lg font-bold text-zinc-300">District Soil Health Trends</h3>
              <p className="text-sm text-zinc-500 max-w-sm mt-1">Aggregated data from {summary?.total_farmers || 0} farmers showing NPK stability across the region.</p>
            </div>
            <p className="text-[10px] text-zinc-600 uppercase font-black tracking-widest">Chart Visualization Loading...</p>
          </div>

          <div className="grid gap-4 md:grid-cols-2">
            <div className="p-5 rounded-2xl border border-zinc-800 bg-zinc-900/40 space-y-4">
               <h4 className="text-xs font-bold uppercase tracking-widest text-zinc-500">Top Crops by Area</h4>
               <div className="space-y-3">
                  {[
                    { name: 'Rice (Sali)', area: '4500 Bigha', pct: 65 },
                    { name: 'Tea', area: '1200 Bigha', pct: 15 },
                    { name: 'Jute', area: '800 Bigha', pct: 10 },
                  ].map(crop => (
                    <div key={crop.name} className="space-y-1.5">
                      <div className="flex justify-between text-xs font-bold">
                        <span>{crop.name}</span>
                        <span className="text-zinc-500">{crop.area}</span>
                      </div>
                      <div className="h-1 w-full bg-zinc-800 rounded-full overflow-hidden">
                        <div className="h-full bg-blue-500" style={{ width: `${crop.pct}%` }} />
                      </div>
                    </div>
                  ))}
               </div>
            </div>
            <div className="p-5 rounded-2xl border border-zinc-800 bg-zinc-900/40 space-y-4">
               <h4 className="text-xs font-bold uppercase tracking-widest text-zinc-500">Field Worker Coverage</h4>
               <div className="space-y-3">
                  {[
                    { name: 'FW-001 (Nagaon)', farmers: 45, status: 'Active' },
                    { name: 'FW-002 (Koliabor)', farmers: 32, status: 'Active' },
                    { name: 'FW-003 (Raha)', farmers: 12, status: 'On Field' },
                  ].map(worker => (
                    <div key={worker.name} className="flex items-center justify-between p-2 rounded-lg bg-zinc-950/50 border border-zinc-800/50">
                      <div>
                        <p className="text-xs font-bold text-zinc-300">{worker.name}</p>
                        <p className="text-[10px] text-zinc-500">{worker.farmers} Farmers Assigned</p>
                      </div>
                      <span className="text-[9px] font-black uppercase text-emerald-500">{worker.status}</span>
                    </div>
                  ))}
               </div>
            </div>
          </div>
        </div>

        {/* Alerts & Communication */}
        <div className="space-y-6">
          <div className="p-6 rounded-2xl border border-zinc-800 bg-red-500/5 space-y-4">
            <h3 className="text-sm font-bold uppercase tracking-widest text-red-500 flex items-center gap-2">
              <AlertTriangle className="h-4 w-4" /> Active Alerts
            </h3>
            <div className="space-y-3">
              <div className="p-3 rounded-xl bg-zinc-950/50 border border-red-500/20">
                <p className="text-xs font-bold text-zinc-200">Rice Swarming Caterpillar</p>
                <p className="text-[10px] text-zinc-500 mt-1">Status: Published • High Severity</p>
                <Button variant="link" className="text-[10px] p-0 h-auto text-blue-500 mt-2">View Details <ChevronRight className="h-3 w-3" /></Button>
              </div>
            </div>
            <Button className="w-full bg-red-600 hover:bg-red-500 text-white font-bold h-10 text-xs gap-2">
               Publish New Alert
            </Button>
          </div>

          <div className="p-6 rounded-2xl border border-zinc-800 bg-zinc-900/20 space-y-4">
             <h3 className="text-xs font-bold uppercase tracking-widest text-zinc-500">Mandi Price Summary</h3>
             <div className="space-y-3">
                <div className="flex items-center justify-between">
                   <span className="text-xs text-zinc-400">Avg Rice Price</span>
                   <span className="text-xs font-bold text-emerald-500">₹2,450 (+2%)</span>
                </div>
                <div className="flex items-center justify-between">
                   <span className="text-xs text-zinc-400">Avg Jute Price</span>
                   <span className="text-xs font-bold text-red-500">₹5,800 (-1%)</span>
                </div>
             </div>
             <Button variant="outline" className="w-full border-zinc-800 text-[10px] font-black uppercase tracking-widest h-9">
               District Price Analysis
             </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
