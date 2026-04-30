'use client';

import { useState } from 'react';
import { supabase } from '@/lib/supabase';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { 
  Dialog, 
  DialogContent, 
  DialogDescription, 
  DialogFooter, 
  DialogHeader, 
  DialogTitle, 
  DialogTrigger 
} from '@/components/ui/dialog';
import { Shovel, Loader2, FlaskConical } from 'lucide-react';
import { useQueryClient } from '@tanstack/react-query';

export function SoilSampleDialog({ fieldId, fieldName }: { fieldId: string, fieldName: string }) {
  const [open, setOpen] = useState(false);
  const [nitrogen, setNitrogen] = useState('');
  const [phosphorus, setPhosphorus] = useState('');
  const [potassium, setPotassium] = useState('');
  const [ph, setPh] = useState('');
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const queryClient = useQueryClient();

  const handleSave = async () => {
    if (!nitrogen || !phosphorus || !potassium || !ph) {
      setError('Please fill in all NPK and pH values.');
      return;
    }

    setIsSaving(true);
    setError(null);
    try {
      const { error: saveError } = await supabase.from('soil_records').insert({
        field_id: fieldId,
        nitrogen: parseFloat(nitrogen),
        phosphorus: parseFloat(phosphorus),
        potassium: parseFloat(potassium),
        ph_level: parseFloat(ph),
        test_date: new Date().toISOString().split('T')[0],
      });

      if (saveError) throw saveError;

      // Invalidate both fields and soil records to refresh the UI
      queryClient.invalidateQueries({ queryKey: ['farmer_fields'] });
      setOpen(false);
      // Reset form
      setNitrogen('');
      setPhosphorus('');
      setPotassium('');
      setPh('');
    } catch (err: any) {
      setError(err.message);
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button size="sm" variant="outline" className="h-8 border-emerald-500/30 text-emerald-500 hover:bg-emerald-500/10 gap-2">
          <FlaskConical className="h-3 w-3" /> Record Soil Test
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-[425px] bg-zinc-900 border-zinc-800 text-white">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <Shovel className="h-5 w-5 text-emerald-500" />
            Soil Health Record
          </DialogTitle>
          <DialogDescription className="text-zinc-400">
            Enter test results for <span className="text-white font-medium">{fieldName}</span>.
          </DialogDescription>
        </DialogHeader>
        <div className="grid gap-6 py-4">
          <div className="grid grid-cols-3 gap-4">
            <div className="grid gap-2 text-center">
              <Label htmlFor="n" className="text-xs text-zinc-500">Nitrogen (N)</Label>
              <Input 
                id="n" 
                type="number" 
                placeholder="mg/kg" 
                value={nitrogen}
                onChange={(e) => setNitrogen(e.target.value)}
                className="bg-zinc-800 border-zinc-700 text-center text-lg font-bold text-emerald-400" 
              />
            </div>
            <div className="grid gap-2 text-center">
              <Label htmlFor="p" className="text-xs text-zinc-500">Phosphorus (P)</Label>
              <Input 
                id="p" 
                type="number" 
                placeholder="mg/kg" 
                value={phosphorus}
                onChange={(e) => setPhosphorus(e.target.value)}
                className="bg-zinc-800 border-zinc-700 text-center text-lg font-bold text-blue-400" 
              />
            </div>
            <div className="grid gap-2 text-center">
              <Label htmlFor="k" className="text-xs text-zinc-500">Potassium (K)</Label>
              <Input 
                id="k" 
                type="number" 
                placeholder="mg/kg" 
                value={potassium}
                onChange={(e) => setPotassium(e.target.value)}
                className="bg-zinc-800 border-zinc-700 text-center text-lg font-bold text-orange-400" 
              />
            </div>
          </div>
          <div className="grid gap-2">
            <Label htmlFor="ph">pH Level (Acidity/Alkalinity)</Label>
            <div className="flex items-center gap-4">
              <Input 
                id="ph" 
                type="number" 
                step="0.1" 
                placeholder="e.g. 6.5" 
                value={ph}
                onChange={(e) => setPh(e.target.value)}
                className="bg-zinc-800 border-zinc-700 text-xl font-bold" 
              />
              <div className="flex-1 h-2 rounded-full bg-gradient-to-r from-red-500 via-green-500 to-blue-500" />
            </div>
            <p className="text-[10px] text-zinc-500">Normal range: 5.5 to 7.5</p>
          </div>
        </div>

        {error && <p className="text-xs text-red-400">{error}</p>}

        <DialogFooter>
          <Button 
            className="w-full bg-emerald-600 hover:bg-emerald-700 text-white py-6" 
            onClick={handleSave}
            disabled={isSaving}
          >
            {isSaving ? <Loader2 className="h-4 w-4 animate-spin mr-2" /> : null}
            Save Soil Data
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
