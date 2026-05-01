'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import { Sparkles, Loader2, TrendingUp, Calendar, ChevronRight, Info } from 'lucide-react';
import { motion } from 'framer-motion';

interface CropRecommendation {
  crop_name: string;
  confidence_score: number;
  sowing_month: string;
  harvest_month: string;
  reasoning: string;
}

export function RecommendationDialog({ fieldId, fieldName, farmerId, latestSoilRecordId }: { 
  fieldId: string, 
  fieldName: string,
  farmerId: string,
  latestSoilRecordId?: string 
}) {
  const [isOpen, setIsOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [recommendations, setRecommendations] = useState<CropRecommendation[]>([]);

  const fetchRecommendations = async () => {
    if (!latestSoilRecordId) return;
    
    setIsLoading(true);
    try {
      const response = await fetch('http://localhost:8000/api/v1/recommend', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          field_id: fieldId,
          soil_record_id: latestSoilRecordId,
          user_id: farmerId // This will be the generated_by field
        }),
      });

      const data = await response.json();
      if (data.recommended_crops) {
        setRecommendations(data.recommended_crops);
      }
    } catch (error) {
      console.error('Error fetching recommendations:', error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <Dialog open={isOpen} onOpenChange={(open) => {
      setIsOpen(open);
      if (open) fetchRecommendations();
    }}>
      <DialogTrigger asChild>
        <Button 
          disabled={!latestSoilRecordId}
          className="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-bold gap-2"
        >
          <Sparkles className="h-4 w-4" /> 
          Get AI Recommendation
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-[500px] bg-zinc-950 border-zinc-800 text-white p-0 overflow-hidden">
        <div className="bg-emerald-500/10 p-6 border-b border-zinc-800">
          <DialogHeader>
            <DialogTitle className="text-2xl font-bold flex items-center gap-2">
              <Sparkles className="h-6 w-6 text-emerald-500" />
              AI Crop Analysis
            </DialogTitle>
            <DialogDescription className="text-zinc-400">
              Optimal crops for <span className="text-white font-medium">{fieldName}</span> based on recent soil health.
            </DialogDescription>
          </DialogHeader>
        </div>

        <div className="p-6 max-h-[400px] overflow-y-auto">
          {isLoading ? (
            <div className="flex flex-col items-center justify-center py-20 gap-4">
              <Loader2 className="h-10 w-10 animate-spin text-emerald-500" />
              <p className="text-zinc-400 animate-pulse text-sm">NVIDIA AI is calculating crop suitability...</p>
            </div>
          ) : recommendations.length > 0 ? (
            <div className="space-y-4">
              {recommendations.map((crop, idx) => (
                <motion.div
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: idx * 0.1 }}
                  key={crop.crop_name}
                  className="p-4 rounded-xl border border-zinc-800 bg-zinc-900/50 hover:border-emerald-500/30 transition-all group"
                >
                  <div className="flex items-center justify-between mb-3">
                    <h4 className="text-lg font-bold flex items-center gap-2">
                      <span className="text-emerald-500">#{idx + 1}</span> {crop.crop_name}
                    </h4>
                    <div className="text-right">
                      <p className="text-[10px] text-zinc-500 uppercase font-bold tracking-tighter">Confidence</p>
                      <p className="text-emerald-400 font-bold">{crop.confidence_score}%</p>
                    </div>
                  </div>

                  {/* Suitability Bar */}
                  <div className="w-full h-1.5 bg-zinc-800 rounded-full mb-4 overflow-hidden">
                    <motion.div 
                      initial={{ width: 0 }}
                      animate={{ width: `${crop.confidence_score}%` }}
                      className="h-full bg-emerald-500" 
                    />
                  </div>

                  <div className="grid grid-cols-2 gap-4 text-xs mb-3">
                    <div className="flex items-center gap-2 text-zinc-400">
                      <Calendar className="h-3 w-3 text-zinc-600" />
                      <span>Sow: <b className="text-zinc-200">{crop.sowing_month}</b></span>
                    </div>
                    <div className="flex items-center gap-2 text-zinc-400">
                      <TrendingUp className="h-3 w-3 text-zinc-600" />
                      <span>Harvest: <b className="text-zinc-200">{crop.harvest_month}</b></span>
                    </div>
                  </div>

                  <div className="flex items-start gap-2 bg-zinc-950/50 p-2.5 rounded-lg border border-zinc-800/50">
                    <Info className="h-3.5 w-3.5 text-emerald-500 shrink-0 mt-0.5" />
                    <p className="text-[11px] text-zinc-500 leading-relaxed italic">
                      {crop.reasoning}
                    </p>
                  </div>
                </motion.div>
              ))}
            </div>
          ) : (
            <div className="text-center py-10 text-zinc-500">
              No recommendations found. Try updating soil data.
            </div>
          )}
        </div>

        <div className="p-4 bg-zinc-900/50 border-t border-zinc-800">
          <Button className="w-full bg-zinc-800 hover:bg-zinc-700 text-white font-medium" onClick={() => setIsOpen(false)}>
            Close Analysis
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}
