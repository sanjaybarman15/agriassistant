'use client';

import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/store/use-auth-store';
import { FarmerOnboarding } from '@/components/dashboard/farmer-onboarding';
import { AddFieldDialog } from '@/components/dashboard/add-field-dialog';
import { SoilSampleDialog } from '@/components/dashboard/soil-sample-dialog';
import { RecommendationDialog } from '@/components/dashboard/recommendation-dialog';
import { MandiPricesWidget } from '@/components/dashboard/mandi-prices-widget';
import { AIAdvisoryPanel } from '@/components/dashboard/ai-advisory-panel';
import { Loader2, Map as MapIcon, Shovel, ThermometerSun, Wind, FlaskConical, ChevronRight, Store } from 'lucide-react';
import { useQuery } from '@tanstack/react-query';

export default function FarmerDashboard() {
  const { user, role } = useAuthStore();

  // 1. Fetch Farmer Basic Profile
  const { data: farmer, isLoading: isFarmerLoading, refetch: refetchFarmer } = useQuery({
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

  // 2. Fetch Farmer Fields + Latest Soil Record
  const { data: fields = [], isLoading: isFieldsLoading } = useQuery({
    queryKey: ['farmer_fields', farmer?.id],
    queryFn: async () => {
      if (!farmer?.id) return [];
      const { data, error } = await supabase
        .from('fields')
        .select(`
          *,
          soil_records (
            nitrogen_kg_ha,
            phosphorus_kg_ha,
            potassium_kg_ha,
            ph_level,
            sample_date
          )
        `)
        .eq('farmer_id', farmer.id)
        .order('created_at', { ascending: false });
      
      if (error) throw error;
      
      // Map to get only the latest soil record per field
      return data.map(field => ({
        ...field,
        latest_soil: field.soil_records?.sort((a: any, b: any) => 
          new Date(b.sample_date).getTime() - new Date(a.sample_date).getTime()
        )[0]
      }));
    },
    enabled: !!farmer?.id,
  });

  // 3. Fetch Real-time Weather
  const { data: weather, isLoading: isWeatherLoading } = useQuery({
    queryKey: ['weather', farmer?.village_location],
    queryFn: async () => {
      if (!farmer?.village_location) return null;
      
      let lat, lon;
      const decodeWKB = (wkb: string) => {
        try {
          const buffer = new Uint8Array(wkb.match(/.{1,2}/g)!.map(byte => parseInt(byte, 16))).buffer;
          const view = new DataView(buffer);
          const isLittleEndian = view.getUint8(0) === 1;
          const lon = view.getFloat64(9, isLittleEndian);
          const lat = view.getFloat64(17, isLittleEndian);
          return { lat, lon };
        } catch (e) { return null; }
      };

      if (typeof farmer.village_location === 'object' && farmer.village_location.coordinates) {
        [lon, lat] = farmer.village_location.coordinates;
      } else if (typeof farmer.village_location === 'string') {
        const decoded = decodeWKB(farmer.village_location);
        if (decoded) { lat = decoded.lat; lon = decoded.lon; }
      }
      
      if (!lat || !lon) return null;

      const res = await fetch(`https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current_weather=true`);
      return res.json();
    },
    enabled: !!farmer?.village_location,
  });

  if (isFarmerLoading || !user) {
    return (
      <div className="flex h-[50vh] items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-emerald-500" />
      </div>
    );
  }

  if (role === 'farmer' && !farmer?.district_id) {
    return (
      <div className="max-w-2xl mx-auto pt-10">
        <FarmerOnboarding onComplete={() => refetchFarmer()} />
      </div>
    );
  }

  const currentTemp = weather?.current_weather?.temperature;
  const windSpeed = weather?.current_weather?.windspeed;

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-4">
        <div className="space-y-1">
          <h1 className="text-3xl font-bold tracking-tight">Farmer Dashboard</h1>
          <div className="flex items-center gap-2 text-zinc-400">
            <span className="text-emerald-500 font-medium">{farmer?.village}</span>
            <span className="h-1 w-1 rounded-full bg-zinc-700" />
            <span>{farmer?.districts?.name}, Assam</span>
          </div>
        </div>
        <AddFieldDialog farmerId={farmer?.id} />
      </div>
      
      {/* Overview */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <div className="rounded-xl border border-zinc-800 bg-zinc-900/50 p-6 space-y-2 hover:border-emerald-500/20 transition-colors">
          <div className="flex items-center justify-between">
            <h3 className="text-sm font-medium text-zinc-400">My Fields</h3>
            <MapIcon className="h-4 w-4 text-emerald-500" />
          </div>
          <p className="text-3xl font-bold">{fields.length}</p>
        </div>
        <div className="rounded-xl border border-zinc-800 bg-zinc-900/50 p-6 space-y-2 hover:border-orange-500/20 transition-colors">
          <div className="flex items-center justify-between">
            <h3 className="text-sm font-medium text-zinc-400">Active Alerts</h3>
            <Wind className="h-4 w-4 text-orange-500" />
          </div>
          <p className="text-3xl font-bold">{isWeatherLoading ? '...' : windSpeed ? `${windSpeed} km/h` : '0'}</p>
        </div>
        <div className="rounded-xl border border-zinc-800 bg-zinc-900/50 p-6 space-y-2 hover:border-emerald-500/20 transition-colors">
          <div className="flex items-center justify-between">
            <h3 className="text-sm font-medium text-zinc-400">Soil Samples</h3>
            <FlaskConical className="h-4 w-4 text-emerald-500" />
          </div>
          <p className="text-3xl font-bold">{fields.filter(f => f.latest_soil).length}</p>
        </div>
        <div className="rounded-xl border border-zinc-800 bg-zinc-900/50 p-6 space-y-2 hover:border-yellow-500/20 transition-colors">
          <div className="flex items-center justify-between">
            <h3 className="text-sm font-medium text-zinc-400">Weather</h3>
            <ThermometerSun className="h-4 w-4 text-yellow-500" />
          </div>
          <p className="text-3xl font-bold">{isWeatherLoading ? <Loader2 className="h-5 w-5 animate-spin" /> : currentTemp ? `${currentTemp}°C` : 'N/A'}</p>
        </div>
      </div>

      {/* Main Content Grid */}
      <div className="grid gap-8 lg:grid-cols-3">
        {/* Fields List (Left 2/3) */}
        <div className="lg:col-span-2 space-y-4">
          <h2 className="text-xl font-semibold flex items-center gap-2">
            Registered Fields 
            <span className="text-[10px] bg-zinc-800 text-zinc-400 px-2 py-1 rounded uppercase tracking-tighter font-bold">Manage Your Plots</span>
          </h2>
          {isFieldsLoading ? (
            <div className="flex justify-center py-10"><Loader2 className="h-6 w-6 animate-spin text-zinc-500" /></div>
          ) : fields.length > 0 ? (
            <div className="grid gap-4 md:grid-cols-2">
              {fields.map((field) => (
                <div key={field.id} className="group relative overflow-hidden rounded-xl border border-zinc-800 bg-zinc-900/50 p-5 hover:border-emerald-500/50 transition-all">
                  <div className="space-y-4">
                    <div className="flex items-center justify-between">
                      <h4 className="font-bold text-lg">{field.name}</h4>
                      <span className="px-2 py-0.5 rounded text-[10px] font-bold uppercase bg-zinc-800 text-zinc-400 border border-zinc-700">
                        {field.soil_type}
                      </span>
                    </div>
                    
                    <div className="grid grid-cols-2 gap-4 text-sm">
                      <div className="space-y-1">
                        <p className="text-[10px] uppercase tracking-wider text-zinc-600 font-bold">Area</p>
                        <p className="text-white font-medium">{field.area_bigha} Bigha</p>
                      </div>
                      <div className="space-y-1">
                        <p className="text-[10px] uppercase tracking-wider text-zinc-600 font-bold">Soil Health</p>
                        {field.latest_soil ? (
                          <p className="text-emerald-500 font-bold flex items-center gap-1">
                            pH {field.latest_soil.ph_level} <ChevronRight className="h-3 w-3" />
                          </p>
                        ) : (
                          <p className="text-zinc-500 font-medium italic">No Data</p>
                        )}
                      </div>
                    </div>

                    {field.latest_soil && (
                      <div className="flex gap-2 pt-1">
                        <div className="flex-1 bg-zinc-950/50 rounded p-2 text-center border border-zinc-800/50">
                          <p className="text-[8px] text-zinc-600 font-bold">N</p>
                          <p className="text-xs font-bold text-emerald-400">{field.latest_soil.nitrogen_kg_ha}</p>
                        </div>
                        <div className="flex-1 bg-zinc-950/50 rounded p-2 text-center border border-zinc-800/50">
                          <p className="text-[8px] text-zinc-600 font-bold">P</p>
                          <p className="text-xs font-bold text-blue-400">{field.latest_soil.phosphorus_kg_ha}</p>
                        </div>
                        <div className="flex-1 bg-zinc-950/50 rounded p-2 text-center border border-zinc-800/50">
                          <p className="text-[8px] text-zinc-600 font-bold">K</p>
                          <p className="text-xs font-bold text-orange-400">{field.latest_soil.potassium_kg_ha}</p>
                        </div>
                      </div>
                    )}

                    <div className="pt-4 space-y-2">
                      <SoilSampleDialog fieldId={field.id} fieldName={field.name} />
                      <RecommendationDialog 
                        fieldId={field.id} 
                        fieldName={field.name} 
                        farmerId={farmer?.id}
                        latestSoilRecordId={field.latest_soil?.id}
                      />
                    </div>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="flex flex-col items-center justify-center py-20 rounded-2xl border border-dashed border-zinc-800 bg-zinc-900/20">
              <MapIcon className="h-10 w-10 text-zinc-700 mb-4" />
              <p className="text-zinc-500">No fields registered yet.</p>
            </div>
          )}
        </div>

        {/* Mandi Prices (Right 1/3) */}
        <div className="space-y-4">
          <h2 className="text-xl font-semibold flex items-center gap-2">
            Market Rates
            <span className="text-[10px] bg-orange-500/10 text-orange-500 px-2 py-1 rounded uppercase tracking-tighter font-bold">Live APMC</span>
          </h2>
          <div className="h-[600px]">
            <MandiPricesWidget districtId={farmer?.district_id} />
          </div>
        </div>
      </div>

      <AIAdvisoryPanel farmerId={farmer?.id} />
    </div>
  );
}
