'use client';

import { useState } from 'react';
import { supabase } from '@/lib/supabase';
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { 
  BellRing, 
  AlertTriangle, 
  CheckCircle2, 
  Loader2,
  Bug
} from 'lucide-react';

export function IssueAlertModal({ districtId, userId }: { districtId: string, userId: string }) {
  const [isOpen, setIsOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);

  const [formData, setFormData] = useState({
    title: '',
    description: '',
    severity: 'medium',
    affected_crops: '',
    advisory: ''
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    try {
      const { error } = await supabase.from('pest_alerts').insert({
        district_id: districtId,
        created_by: userId,
        title: formData.title,
        description: formData.description,
        severity: formData.severity,
        affected_crops: formData.affected_crops.split(',').map(c => c.trim()),
        advisory: formData.advisory,
        status: 'published'
      });

      if (error) throw error;
      
      setIsSuccess(true);
      setTimeout(() => {
        setIsOpen(false);
        setIsSuccess(false);
        setFormData({ title: '', description: '', severity: 'medium', affected_crops: '', advisory: '' });
      }, 2000);

    } catch (error) {
      console.error('Error issuing alert:', error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <Dialog open={isOpen} onOpenChange={setIsOpen}>
      <DialogTrigger asChild>
        <Button className="bg-red-600 hover:bg-red-500 text-white font-bold h-12 px-6 rounded-xl shadow-lg shadow-red-900/20 gap-2">
          <BellRing className="h-5 w-5" /> Issue Pest Alert
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-[500px] bg-zinc-950 border-zinc-800 text-white">
        <DialogHeader>
          <DialogTitle className="text-xl font-bold flex items-center gap-2">
            <AlertTriangle className="h-5 w-5 text-red-500" />
            Issue District Pest Alert
          </DialogTitle>
          <DialogDescription className="text-zinc-500 italic">
            This alert will be broadcasted to all farmers in your district.
          </DialogDescription>
        </DialogHeader>

        {isSuccess ? (
          <div className="py-20 flex flex-col items-center justify-center gap-4 text-center">
            <div className="h-16 w-16 rounded-full bg-emerald-500/20 flex items-center justify-center">
              <CheckCircle2 className="h-10 w-10 text-emerald-500" />
            </div>
            <h3 className="text-xl font-bold">Alert Published!</h3>
            <p className="text-zinc-500 text-sm">Farmers will be notified immediately.</p>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-4 py-4">
            <div className="space-y-1.5">
              <label className="text-[10px] font-bold uppercase text-zinc-500">Alert Title</label>
              <Input 
                required
                value={formData.title}
                onChange={e => setFormData({...formData, title: e.target.value})}
                placeholder="e.g., Rice Swarming Caterpillar Outbreak" 
                className="bg-zinc-900 border-zinc-800"
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <label className="text-[10px] font-bold uppercase text-zinc-500">Severity</label>
                <select 
                  className="w-full h-10 rounded-md bg-zinc-900 border border-zinc-800 px-3 text-sm text-zinc-300 focus:outline-none focus:ring-1 focus:ring-red-500"
                  value={formData.severity}
                  onChange={e => setFormData({...formData, severity: e.target.value})}
                >
                  <option value="low">Low</option>
                  <option value="medium">Medium</option>
                  <option value="high">High</option>
                  <option value="critical">Critical</option>
                </select>
              </div>
              <div className="space-y-1.5">
                <label className="text-[10px] font-bold uppercase text-zinc-500">Affected Crops</label>
                <Input 
                  required
                  value={formData.affected_crops}
                  onChange={e => setFormData({...formData, affected_crops: e.target.value})}
                  placeholder="Rice, Jute, etc." 
                  className="bg-zinc-900 border-zinc-800"
                />
              </div>
            </div>

            <div className="space-y-1.5">
              <label className="text-[10px] font-bold uppercase text-zinc-500">Description</label>
              <Textarea 
                required
                value={formData.description}
                onChange={e => setFormData({...formData, description: e.target.value})}
                placeholder="Details of the outbreak and location..." 
                className="bg-zinc-900 border-zinc-800 min-h-[100px]"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-[10px] font-bold uppercase text-zinc-500">Advisory Action</label>
              <Textarea 
                required
                value={formData.advisory}
                onChange={e => setFormData({...formData, advisory: e.target.value})}
                placeholder="What should farmers do immediately?" 
                className="bg-emerald-500/5 border-emerald-500/20 min-h-[80px]"
              />
            </div>

            <Button 
              type="submit" 
              disabled={isLoading}
              className="w-full bg-red-600 hover:bg-red-500 text-white font-bold h-12 rounded-xl mt-4 gap-2"
            >
              {isLoading ? <Loader2 className="h-5 w-5 animate-spin" /> : <Bug className="h-5 w-5" />}
              Broadcast Alert Now
            </Button>
          </form>
        )}
      </DialogContent>
    </Dialog>
  );
}
