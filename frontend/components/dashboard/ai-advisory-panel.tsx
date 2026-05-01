'use client';

import { useState, useEffect, useRef } from 'react';
import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/store/use-auth-store';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { ScrollArea } from '@/components/ui/scroll-area';
import { 
  Bot, 
  User, 
  Send, 
  Loader2, 
  X, 
  MessageSquare, 
  Sparkles,
  ChevronDown
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

interface Message {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  created_at: string;
}

export function AIAdvisoryPanel({ farmerId, currentFieldId }: { farmerId: string, currentFieldId?: string }) {
  const [isOpen, setIsOpen] = useState(false);
  const [query, setQuery] = useState('');
  const [messages, setMessages] = useState<Message[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [sessionId, setSessionId] = useState<string | null>(null);
  const scrollRef = useRef<HTMLDivElement>(null);

  // Fetch or create session and history
  useEffect(() => {
    if (isOpen && farmerId) {
      loadChatHistory();
    }
  }, [isOpen, farmerId]);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages]);

  const loadChatHistory = async () => {
    // 1. Get latest session for this farmer/field
    const { data: sessions } = await supabase
      .from('chat_sessions')
      .select('id')
      .eq('farmer_id', farmerId)
      .order('updated_at', { ascending: false })
      .limit(1);

    if (sessions && sessions.length > 0) {
      const activeSessionId = sessions[0].id;
      setSessionId(activeSessionId);

      // 2. Load messages
      const { data: msgs } = await supabase
        .from('chat_messages')
        .select('*')
        .eq('session_id', activeSessionId)
        .order('created_at', { ascending: true });

      if (msgs) setMessages(msgs);
    }
  };

  const handleSend = async () => {
    if (!query.trim() || isLoading) return;

    const userQuery = query;
    setQuery('');
    setIsLoading(true);

    // Optimistic Update
    const tempId = Date.now().toString();
    setMessages(prev => [...prev, { 
      id: tempId, 
      role: 'user', 
      content: userQuery, 
      created_at: new Date().toISOString() 
    }]);

    try {
      const response = await fetch('http://localhost:8000/api/v1/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          query: userQuery,
          farmer_id: farmerId,
          field_id: currentFieldId,
          session_id: sessionId
        }),
      });

      const result = await response.json();

      if (result.response) {
        if (!sessionId) setSessionId(result.session_id);
        
        setMessages(prev => [...prev, { 
          id: Date.now().toString(), 
          role: 'assistant', 
          content: result.response, 
          created_at: new Date().toISOString() 
        }]);
      }
    } catch (error) {
      console.error('Chat error:', error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="fixed bottom-6 right-6 z-50">
      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0, y: 20, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 20, scale: 0.95 }}
            className="mb-4 w-[380px] h-[550px] bg-zinc-950 border border-zinc-800 rounded-2xl shadow-2xl overflow-hidden flex flex-col"
          >
            {/* Header */}
            <div className="p-4 border-b border-zinc-800 bg-emerald-500/5 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="h-8 w-8 rounded-full bg-emerald-500/20 flex items-center justify-center">
                  <Bot className="h-5 w-5 text-emerald-500" />
                </div>
                <div>
                  <h3 className="font-bold text-sm">AgriAdvisor</h3>
                  <div className="flex items-center gap-1.5">
                    <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
                    <span className="text-[10px] text-zinc-500 font-medium uppercase tracking-wider">NVIDIA NIM Active</span>
                  </div>
                </div>
              </div>
              <Button variant="ghost" size="icon" onClick={() => setIsOpen(false)} className="h-8 w-8 text-zinc-500">
                <ChevronDown className="h-5 w-5" />
              </Button>
            </div>

            {/* Messages Area */}
            <ScrollArea className="flex-1 p-4" viewportRef={scrollRef}>
              <div className="space-y-4">
                {messages.length === 0 && (
                  <div className="py-10 text-center space-y-3">
                    <Sparkles className="h-8 w-8 text-emerald-500/30 mx-auto" />
                    <p className="text-zinc-500 text-sm px-10 italic">
                      "Namaskar! Ask me anything about your crops, pests, or soil health in Assam."
                    </p>
                  </div>
                )}
                {messages.map((msg) => (
                  <div
                    key={msg.id}
                    className={`flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}
                  >
                    <div
                      className={`max-w-[85%] p-3 rounded-2xl text-sm ${
                        msg.role === 'user'
                          ? 'bg-emerald-600 text-white rounded-tr-none'
                          : 'bg-zinc-900 border border-zinc-800 text-zinc-200 rounded-tl-none'
                      }`}
                    >
                      {msg.content}
                    </div>
                  </div>
                ))}
                {isLoading && (
                  <div className="flex justify-start">
                    <div className="bg-zinc-900 border border-zinc-800 p-3 rounded-2xl rounded-tl-none flex items-center gap-2">
                      <Loader2 className="h-4 w-4 animate-spin text-emerald-500" />
                      <span className="text-xs text-zinc-500">Analyzing...</span>
                    </div>
                  </div>
                )}
              </div>
            </ScrollArea>

            {/* Input Area */}
            <div className="p-4 border-t border-zinc-800 bg-zinc-950">
              <div className="relative">
                <Input
                  value={query}
                  onChange={(e) => setQuery(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && handleSend()}
                  placeholder="Type your question..."
                  className="bg-zinc-900 border-zinc-800 pr-12 h-11 text-sm focus-visible:ring-emerald-500"
                />
                <Button
                  size="icon"
                  disabled={!query.trim() || isLoading}
                  onClick={handleSend}
                  className="absolute right-1.5 top-1.5 h-8 w-8 bg-emerald-600 hover:bg-emerald-500 text-white"
                >
                  <Send className="h-4 w-4" />
                </Button>
              </div>
              <p className="mt-2 text-[9px] text-center text-zinc-600 uppercase font-bold tracking-widest">
                AI can make mistakes. Verify critical actions.
              </p>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      <Button
        onClick={() => setIsOpen(!isOpen)}
        className={`h-14 w-14 rounded-full shadow-2xl transition-all duration-300 ${
          isOpen ? 'bg-zinc-900 rotate-90' : 'bg-emerald-600 hover:bg-emerald-500'
        }`}
      >
        {isOpen ? <X className="h-6 w-6" /> : <MessageSquare className="h-6 w-6" />}
      </Button>
    </div>
  );
}
