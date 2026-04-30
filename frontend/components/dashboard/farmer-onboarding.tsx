'use client';

import { useState } from 'react';
import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/store/use-auth-store';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { MapPin, MapPinned, Loader2, Sparkles, AlertCircle } from 'lucide-react';
import { useQuery } from '@tanstack/react-query';

interface District {
  id: string;
  name: string;
}

export function FarmerOnboarding({ onComplete }: { onComplete: () => void }) {
  const { user } = useAuthStore();
  const [village, setVillage] = useState('');
  const [districtId, setDistrictId] = useState('');
  const [coords, setCoords] = useState<{ lat: number, lon: number } | null>(null);
  const [isLocating, setIsLocating] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Unified fetching for districts
  const { data: districts = [] } = useQuery({
    queryKey: ['districts'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('districts')
        .select('id, name')
        .order('name', { ascending: true });
      if (error) throw error;
      return data as District[];
    }
  });

  const handleGetLocation = () => {
    setIsLocating(true);
    setError(null);

    if (!navigator.geolocation) {
      setError('Geolocation not supported');
      setIsLocating(false);
      return;
    }

    navigator.geolocation.getCurrentPosition(
      async (position) => {
        const { latitude: lat, longitude: lon } = position.coords;
        setCoords({ lat, lon });

        try {
          const response = await fetch(
            `https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${lat}&longitude=${lon}&localityLanguage=en`
          );
          const data = await response.json();

          // 1. Auto-fill Village
          if (data.locality || data.city) setVillage(data.locality || data.city);

          // 2. Smarter District Matching
          const adminLevels = data.localityInfo?.administrative || [];
          console.log('Detected Location Levels:', adminLevels);

          // Look for any admin level name that exists in our district list
          for (const level of adminLevels) {
            const levelName = level.name.toLowerCase();
            const match = districts.find(d => 
              levelName.includes(d.name.toLowerCase()) || 
              d.name.toLowerCase().includes(levelName.replace(' district', ''))
            );
            
            if (match) {
              setDistrictId(match.id);
              break;
            }
          }
        } catch (err) {
          console.error('Reverse Geocoding Error:', err);
        } finally {
          setIsLocating(false);
        }
      },
      (err) => {
        setError('Could not get location. You can still select your district manually below.');
        setIsLocating(false);
      }
    );
  };

  const handleSave = async () => {
    if (!districtId || !village || !user) {
      setError('Please select your District and enter your Village name.');
      return;
    }

    setIsSaving(true);
    try {
      const updateData: any = {
        district_id: districtId,
        village: village,
      };

      if (coords) {
        updateData.village_location = `POINT(${coords.lon} ${coords.lat})`;
      }

      const { error } = await supabase
        .from('farmers')
        .update(updateData)
        .eq('profile_id', user.id);

      if (error) throw error;
      onComplete();
    } catch (err: any) {
      setError(err.message);
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <Card className="border-emerald-500/30 bg-emerald-500/5 backdrop-blur-sm shadow-xl">
      <CardHeader>
        <div className="flex items-center gap-2">
          <Sparkles className="h-5 w-5 text-emerald-500" />
          <CardTitle className="text-xl">Welcome to AgriAssistant!</CardTitle>
        </div>
        <CardDescription className="text-emerald-500/70">
          Set your location to unlock hyper-local weather, mandi prices, and pest alerts.
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="flex items-center justify-between gap-4 p-4 rounded-lg bg-zinc-900/50 border border-zinc-800">
          <div className="space-y-1">
            <p className="text-sm font-medium">Capture your GPS location</p>
            <p className="text-xs text-zinc-500">Highly recommended for precise advisories</p>
          </div>
          <Button 
            onClick={handleGetLocation} 
            disabled={isLocating}
            variant={coords ? "outline" : "default"}
            className={coords ? "border-emerald-500/50 text-emerald-500" : "bg-emerald-600 hover:bg-emerald-700 text-white"}
          >
            {isLocating ? <Loader2 className="h-4 w-4 animate-spin" /> : coords ? <MapPinned className="h-4 w-4 mr-2" /> : <MapPin className="h-4 w-4 mr-2" />}
            {coords ? 'Location Updated' : 'Get My Location'}
          </Button>
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-2">
            <Label>District <span className="text-emerald-500">*</span></Label>
            <Select value={districtId} onValueChange={setDistrictId}>
              <SelectTrigger className="bg-zinc-900 border-zinc-800 focus:ring-emerald-500">
                <SelectValue placeholder="Select District" />
              </SelectTrigger>
              <SelectContent className="bg-zinc-900 border-zinc-800 text-white max-h-[250px]">
                {districts.length > 0 ? (
                  districts.map((d) => (
                    <SelectItem key={d.id} value={d.id}>{d.name}</SelectItem>
                  ))
                ) : (
                  <div className="p-2 text-xs text-zinc-500">Loading districts...</div>
                )}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <Label htmlFor="village">Village Name <span className="text-emerald-500">*</span></Label>
            <Input
              id="village"
              placeholder="Enter village"
              value={village}
              onChange={(e) => setVillage(e.target.value)}
              className="bg-zinc-900 border-zinc-800 focus:ring-emerald-500"
            />
          </div>
        </div>

        {error && (
          <div className="flex items-center gap-2 p-3 rounded-md bg-red-500/10 border border-red-500/20 text-xs text-red-400">
            <AlertCircle className="h-4 w-4 shrink-0" />
            <p>{error}</p>
          </div>
        )}
        
        <Button 
          onClick={handleSave} 
          disabled={isSaving}
          className="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-bold py-6 shadow-lg shadow-emerald-900/20"
        >
          {isSaving ? (
            <div className="flex items-center gap-2">
              <Loader2 className="h-4 w-4 animate-spin" />
              <span>Saving Profile...</span>
            </div>
          ) : 'Finish Setup & Enter Dashboard'}
        </Button>
      </CardContent>
    </Card>
  );
}
