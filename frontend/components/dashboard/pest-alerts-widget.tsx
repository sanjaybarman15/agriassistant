'use client';

import { useQuery } from '@tanstack/react-query';
import { 
  AlertTriangle, 
  Info, 
  X, 
  ChevronRight,
  ShieldAlert,
  Bug,
  Loader2
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { useState } from 'react';

interface PestAlert {
  id: string;
  title: string;
  description: string;
  affected_crops: string[];
  severity: 'low' | 'medium' | 'high' | 'critical';
  advisory: string;
  reported_at: string;
}

export function PestAlertsWidget({ districtId }: { districtId: string }) {
  const [dismissed, setDismissed] = useState<string[]>([]);

  const { data: alerts, isLoading } = useQuery<PestAlert[]>({
    queryKey: ['pest_alerts', districtId],
    queryFn: async () => {
      const res = await fetch(`http://localhost:8000/api/v1/alerts/${districtId}`);
      return res.json();
    },
    enabled: !!districtId,
  });

  const activeAlerts = alerts?.filter(a => !dismissed.includes(a.id)) || [];

  if (isLoading) return null;
  if (activeAlerts.length === 0) return null;

  return (
    <div className="space-y-3 mb-8">
      <div className="flex items-center gap-2 mb-2 px-1">
        <ShieldAlert className="h-4 w-4 text-red-500" />
        <h3 className="text-xs font-bold uppercase tracking-widest text-zinc-400">Pest & Disease Alerts</h3>
      </div>
      
      <AnimatePresence>
        {activeAlerts.map((alert) => (
          <motion.div
            key={alert.id}
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, x: 100 }}
            className={`relative overflow-hidden rounded-xl border p-4 transition-all ${
              alert.severity === 'high' || alert.severity === 'critical'
                ? 'bg-red-500/10 border-red-500/20'
                : 'bg-orange-500/10 border-orange-500/20'
            }`}
          >
            <div className="flex items-start justify-between gap-4">
              <div className="flex items-start gap-4">
                <div className={`mt-1 p-2 rounded-lg ${
                  alert.severity === 'high' || alert.severity === 'critical' ? 'bg-red-500/20' : 'bg-orange-500/20'
                }`}>
                  <Bug className={`h-5 w-5 ${
                    alert.severity === 'high' || alert.severity === 'critical' ? 'text-red-500' : 'text-orange-500'
                  }`} />
                </div>
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <h4 className="font-bold text-zinc-100">{alert.title}</h4>
                    <span className={`text-[10px] font-bold uppercase px-1.5 py-0.5 rounded ${
                      alert.severity === 'high' || alert.severity === 'critical' 
                        ? 'bg-red-500 text-white' 
                        : 'bg-orange-500 text-white'
                    }`}>
                      {alert.severity}
                    </span>
                  </div>
                  <p className="text-sm text-zinc-400 max-w-2xl">{alert.description}</p>
                  
                  <div className="flex flex-wrap gap-2 pt-2">
                    {alert.affected_crops.map(crop => (
                      <span key={crop} className="text-[10px] font-medium bg-zinc-950/50 border border-zinc-800 px-2 py-0.5 rounded text-zinc-300">
                        {crop}
                      </span>
                    ))}
                  </div>

                  {alert.advisory && (
                    <div className="mt-3 p-3 rounded-lg bg-zinc-950/50 border border-zinc-800/50 flex items-start gap-3">
                      <Info className="h-4 w-4 text-emerald-500 shrink-0 mt-0.5" />
                      <div className="space-y-1">
                        <p className="text-[10px] font-bold uppercase text-emerald-500 tracking-wider">Advisory</p>
                        <p className="text-xs text-zinc-300 leading-relaxed">{alert.advisory}</p>
                      </div>
                    </div>
                  )}
                </div>
              </div>

              <button 
                onClick={() => setDismissed([...dismissed, alert.id])}
                className="text-zinc-600 hover:text-white transition-colors p-1"
              >
                <X className="h-4 w-4" />
              </button>
            </div>

            {/* Severity glow effect */}
            <div className={`absolute top-0 right-0 w-32 h-32 -mr-16 -mt-16 rounded-full blur-3xl opacity-20 ${
              alert.severity === 'high' || alert.severity === 'critical' ? 'bg-red-500' : 'bg-orange-500'
            }`} />
          </motion.div>
        ))}
      </AnimatePresence>
    </div>
  );
}
