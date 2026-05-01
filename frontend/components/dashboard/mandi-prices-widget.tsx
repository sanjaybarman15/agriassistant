'use client';

import { useQuery } from '@tanstack/react-query';
import { 
  TrendingUp, 
  TrendingDown, 
  Minus, 
  Store, 
  Loader2, 
  ArrowRightLeft,
  Calendar
} from 'lucide-react';
import { ScrollArea } from '@/components/ui/scroll-area';

interface MandiPrice {
  crop_name: string;
  market_name: string;
  price_inr_per_quintal: number;
  price_date: string;
  trend?: string;
}

export function MandiPricesWidget({ districtId }: { districtId: string }) {
  const { data: prices, isLoading } = useQuery<MandiPrice[]>({
    queryKey: ['mandi_prices', districtId],
    queryFn: async () => {
      const res = await fetch(`http://localhost:8000/api/v1/prices/${districtId}`);
      return res.json();
    },
    enabled: !!districtId,
  });

  return (
    <div className="rounded-xl border border-zinc-800 bg-zinc-900/50 flex flex-col h-full overflow-hidden">
      <div className="p-4 border-b border-zinc-800 flex items-center justify-between bg-zinc-950/30">
        <div className="flex items-center gap-2">
          <Store className="h-4 w-4 text-orange-500" />
          <h3 className="text-sm font-bold uppercase tracking-wider text-zinc-300">Live Mandi Rates</h3>
        </div>
        <div className="px-2 py-0.5 rounded bg-orange-500/10 border border-orange-500/20">
          <span className="text-[10px] font-bold text-orange-500 uppercase">Local Markets</span>
        </div>
      </div>

      <ScrollArea className="flex-1">
        <div className="p-4 space-y-3">
          {isLoading ? (
            <div className="flex flex-col items-center justify-center py-10 gap-2">
              <Loader2 className="h-5 w-5 animate-spin text-zinc-600" />
              <p className="text-xs text-zinc-600 italic">Syncing with APMC...</p>
            </div>
          ) : prices && prices.length > 0 ? (
            prices.map((price, idx) => (
              <div 
                key={`${price.crop_name}-${idx}`} 
                className="flex items-center justify-between p-3 rounded-lg bg-zinc-950/40 border border-zinc-800/50 hover:border-orange-500/30 transition-colors group"
              >
                <div className="space-y-1">
                  <h4 className="text-sm font-bold text-zinc-100 group-hover:text-white transition-colors">{price.crop_name}</h4>
                  <div className="flex items-center gap-2 text-[10px] text-zinc-500">
                    <span className="font-medium text-zinc-400">{price.market_name}</span>
                    <span className="h-1 w-1 rounded-full bg-zinc-800" />
                    <span className="flex items-center gap-1">
                      <Calendar className="h-2.5 w-2.5" />
                      {new Date(price.price_date).toLocaleDateString('en-IN', { day: '2-digit', month: 'short' })}
                    </span>
                  </div>
                </div>
                
                <div className="text-right space-y-1">
                  <p className="text-sm font-bold text-orange-400">₹{price.price_inr_per_quintal.toLocaleString('en-IN')}</p>
                  <p className="text-[10px] text-zinc-600 font-bold uppercase tracking-widest">/ Quintal</p>
                </div>

                {price.trend && (
                  <div className={`ml-4 flex items-center gap-1 text-[10px] font-bold px-1.5 py-0.5 rounded ${
                    price.trend.startsWith('+') ? 'text-emerald-500 bg-emerald-500/10' : 
                    price.trend.startsWith('-') ? 'text-red-500 bg-red-500/10' : 
                    'text-zinc-500 bg-zinc-500/10'
                  }`}>
                    {price.trend.startsWith('+') ? <TrendingUp className="h-2.5 w-2.5" /> : 
                     price.trend.startsWith('-') ? <TrendingDown className="h-2.5 w-2.5" /> : 
                     <Minus className="h-2.5 w-2.5" />}
                    {price.trend}
                  </div>
                )}
              </div>
            ))
          ) : (
            <div className="text-center py-10 text-zinc-600 text-xs italic">
              No prices found for your district.
            </div>
          )}
        </div>
      </ScrollArea>

      <div className="p-3 border-t border-zinc-800 bg-zinc-950/30">
        <button className="w-full flex items-center justify-center gap-2 text-[10px] font-bold text-zinc-500 hover:text-orange-500 transition-colors uppercase tracking-widest">
          View All Markets <ArrowRightLeft className="h-3 w-3" />
        </button>
      </div>
    </div>
  );
}
