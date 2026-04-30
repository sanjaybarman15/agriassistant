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
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Plus, MapPin, Loader2 } from 'lucide-react';
import { useQueryClient } from '@tanstack/react-query';

const SOIL_TYPES = [
  { label: 'Sandy', value: 'sandy' },
  { label: 'Silty', value: 'silty' },
  { label: 'Clay', value: 'clay' },
  { label: 'Loamy', value: 'loamy' },
  { label: 'Peaty', value: 'peaty' },
  { label: 'Chalky', value: 'chalky' },
  { label: 'Char Land (Sandbars)', value: 'char_land' }
];

export function AddFieldDialog({ farmerId }: { farmerId: string }) {
  const [open, setOpen] = useState(false);
  const [name, setName] = useState('');
  const [area, setArea] = useState('');
  const [soilType, setSoilType] = useState('');
  const [coords, setCoords] = useState<{ lat: number, lon: number } | null>(null);
  const [isLocating, setIsLocating] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const queryClient = useQueryClient();

  const handleGetLocation = () => {
    setIsLocating(true);
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        setCoords({ lat: pos.coords.latitude, lon: pos.coords.longitude });
        setIsLocating(false);
      },
      () => setIsLocating(false)
    );
  };

  const handleSave = async () => {
    if (!name || !area || !soilType) return;

    setIsSaving(true);
    try {
      const fieldData: any = {
        farmer_id: farmerId,
        name,
        area_bigha: parseFloat(area),
        soil_type: soilType,
      };

      if (coords) {
        fieldData.location = `POINT(${coords.lon} ${coords.lat})`;
      }

      console.log('Registering Field with data:', fieldData);
      const { error } = await supabase.from('fields').insert(fieldData);
      
      if (error) {
        console.error('Supabase Error:', error);
        throw new Error(error.message);
      }

      queryClient.invalidateQueries({ queryKey: ['farmer_fields'] });
      setOpen(false);
      // Reset form
      setName('');
      setArea('');
      setSoilType('');
      setCoords(null);
    } catch (err: any) {
      console.error('Error saving field:', err.message || err);
      alert(`Could not save field: ${err.message || 'Unknown error'}`);
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button className="bg-emerald-600 hover:bg-emerald-700 text-white gap-2">
          <Plus className="h-4 w-4" /> Add New Field
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-[425px] bg-zinc-900 border-zinc-800 text-white">
        <DialogHeader>
          <DialogTitle>Add New Field</DialogTitle>
          <DialogDescription className="text-zinc-400">
            Enter the details of your plot to get field-specific recommendations.
          </DialogDescription>
        </DialogHeader>
        <div className="grid gap-4 py-4">
          <div className="grid gap-2">
            <Label htmlFor="name">Field Name</Label>
            <Input 
              id="name" 
              placeholder="e.g. North Plot" 
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="bg-zinc-800 border-zinc-700" 
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="grid gap-2">
              <Label htmlFor="area">Area (Bigha)</Label>
              <Input 
                id="area" 
                type="number" 
                placeholder="0.0" 
                value={area}
                onChange={(e) => setArea(e.target.value)}
                className="bg-zinc-800 border-zinc-700" 
              />
            </div>
            <div className="grid gap-2">
              <Label>Soil Type</Label>
              <Select value={soilType} onValueChange={setSoilType}>
                <SelectTrigger className="bg-zinc-800 border-zinc-700">
                  <SelectValue placeholder="Select" />
                </SelectTrigger>
                <SelectContent className="bg-zinc-900 border-zinc-800 text-white">
                  {SOIL_TYPES.map(t => (
                    <SelectItem key={t.value} value={t.value}>{t.label}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>
          <div className="flex items-center justify-between p-3 rounded-lg border border-zinc-800 bg-zinc-950/50">
            <div className="space-y-0.5">
              <p className="text-sm font-medium">Field Center (GPS)</p>
              <p className="text-xs text-zinc-500">
                {coords ? `${coords.lat.toFixed(4)}, ${coords.lon.toFixed(4)}` : 'Not captured yet'}
              </p>
            </div>
            <Button 
              size="sm" 
              variant="outline" 
              onClick={handleGetLocation}
              disabled={isLocating}
              className="border-zinc-700 hover:bg-zinc-800"
            >
              {isLocating ? <Loader2 className="h-4 w-4 animate-spin" /> : <MapPin className="h-4 w-4" />}
            </Button>
          </div>
        </div>
        <DialogFooter>
          <Button 
            className="w-full bg-emerald-600 hover:bg-emerald-700 text-white" 
            onClick={handleSave}
            disabled={isSaving}
          >
            {isSaving ? 'Saving...' : 'Register Field'}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
