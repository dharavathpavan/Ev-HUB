"use client";

import React, { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Terminal, Code, Cpu, ShieldCheck } from "lucide-react";

export default function DeveloperApi() {
  const [eventLogs, setEventLogs] = useState<any[]>([
    {
      timestamp: new Date().toISOString().slice(11, 19),
      event: "charging_authorized",
      charger: "CHG-PHX-A1",
      connector: 1,
      balance: "$150.00",
    },
    {
      timestamp: new Date(Date.now() - 3000).toISOString().slice(11, 19),
      event: "charging_started",
      charger: "CHG-PHX-A1",
      power: "32kW",
    }
  ]);

  // Code snippet to show
  const codeSnippet = `// Initialize Hyperion SDK Client
import { HyperionClient } from "@hyperion/sdk";

const client = new HyperionClient({
  apiKey: "hyp_live_8afc922b01",
  endpoint: "https://api.hyperion.net/v2"
});

// Bind real-time OCPP Event Listener
client.on("charging_started", (session) => {
  console.log(\`[OCPP] Charge started on Gun \${session.gunIndex}\`);
  console.log(\`[STATS] Power output: \${session.maxPower} kW\`);
});

// Trigger dynamic pre-authorized pre-payments
await client.payments.qrInitiate({
  qrId: "QR-CHG-A1-G1",
  walletId: "USER-APP-999",
  preAuthDeposit: 150.00
});`;

  // WebSocket dynamic JSON events simulator
  useEffect(() => {
    const timer = setInterval(() => {
      const chargerIds = ["CHG-PHX-A1", "CHG-VOLT-B2", "CHG-ECO-C3"];
      const events = [
        {
          event: "charging_progress",
          charger: chargerIds[Math.floor(Math.random() * chargerIds.length)],
          power: `${(120 + Math.random() * 200).toFixed(1)}kW`,
          soc: `${Math.floor(50 + Math.random() * 45)}%`,
        },
        {
          event: "payment_authorized",
          charger: chargerIds[Math.floor(Math.random() * chargerIds.length)],
          walletId: `USER-APP-${Math.floor(100 + Math.random() * 899)}`,
          preAuthDeposit: "150.00",
        },
        {
          event: "charging_completed",
          charger: chargerIds[Math.floor(Math.random() * chargerIds.length)],
          energyDelivered: `${(20 + Math.random() * 60).toFixed(1)}kWh`,
          refundIssued: `$${(20 + Math.random() * 100).toFixed(2)}`,
        }
      ];

      const newEvent = {
        timestamp: new Date().toISOString().slice(11, 19),
        ...events[Math.floor(Math.random() * events.length)],
      };

      setEventLogs((prev) => [newEvent, ...prev.slice(0, 3)]);
    }, 2800);

    return () => clearInterval(timer);
  }, []);

  return (
    <section id="developers" className="relative py-24 bg-[#050816] overflow-hidden">
      <div className="absolute inset-0 cyber-grid-dense opacity-20 pointer-events-none" />
      
      <div className="max-w-7xl mx-auto px-6 relative z-10">
        
        {/* Title */}
        <div className="max-w-3xl mb-16">
          <span className="text-xs font-bold uppercase tracking-widest text-[#7b61ff] font-orbitron flex items-center space-x-2">
            <Code className="w-4 h-4 mr-1 text-[#7b61ff] animate-pulse" />
            <span>DEVELOPER SANDBOX</span>
          </span>
          <h2 className="text-3xl md:text-5xl font-black uppercase font-orbitron mt-3 tracking-tight">Futuristic API Suite</h2>
          <p className="text-gray-400 mt-4 text-sm md:text-base">
            Integrate our high-voltage OCPP microservices, track WebSocket charge progress, and initiate secure payouts with our premium client SDK.
          </p>
        </div>

        {/* Console layout */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
          
          {/* Left Column: Code Editor */}
          <div className="glass-panel rounded-2xl border border-white/5 overflow-hidden flex flex-col">
            {/* Top Editor Header tab bar */}
            <div className="bg-[#0b1120] px-6 py-4 border-b border-white/5 flex items-center justify-between">
              <div className="flex items-center space-x-2 text-xs font-mono font-bold text-gray-400">
                <Code className="w-4 h-4 text-[#00d1ff]" />
                <span>client_integration.ts</span>
              </div>
              <span className="text-[9px] font-mono text-cyan-400 border border-cyan-500/20 px-2 py-0.5 rounded">TS SDK</span>
            </div>
            
            {/* Code Body block */}
            <div className="p-6 bg-[#0b1120]/40 overflow-x-auto font-mono text-xs text-gray-300 leading-relaxed min-h-[350px] no-scrollbar">
              <pre><code>{codeSnippet}</code></pre>
            </div>
          </div>

          {/* Right Column: Glowing Event Terminal */}
          <div className="glass-panel rounded-2xl border border-cyan-500/10 shadow-[0_0_30px_rgba(0,209,255,0.02)] overflow-hidden flex flex-col justify-between">
            {/* Terminal Header */}
            <div>
              <div className="bg-[#0b1120] px-6 py-4 border-b border-white/5 flex items-center justify-between">
                <div className="flex items-center space-x-2 text-xs font-mono font-bold text-gray-400">
                  <Terminal className="w-4 h-4 text-[#00ffb2] animate-pulse" />
                  <span>WS_EVENT_STREAM // live_feed</span>
                </div>
                <div className="flex items-center space-x-2">
                  <span className="w-2 h-2 rounded-full bg-[#00ffb2] animate-ping" />
                  <span className="text-[10px] font-mono text-[#00ffb2]">LISTENING</span>
                </div>
              </div>

              {/* Dynamic WebSocket Events list */}
              <div className="p-6 font-mono text-xs space-y-4 min-h-[300px] h-[340px] overflow-y-auto no-scrollbar">
                <AnimatePresence>
                  {eventLogs.map((log, idx) => (
                    <motion.div
                      key={idx}
                      initial={{ opacity: 0, x: -10 }}
                      animate={{ opacity: 1, x: 0 }}
                      exit={{ opacity: 0 }}
                      transition={{ duration: 0.3 }}
                      className="p-4 bg-[#050816]/90 border border-white/5 rounded-lg text-cyan-400"
                    >
                      <div className="flex justify-between items-center text-[10px] text-gray-500 border-b border-white/5 pb-1 mb-2">
                        <span>[ {log.timestamp} ] SOCKET EVENT</span>
                        <span className="text-[#00ffb2]">STATE: ACCEPTED</span>
                      </div>
                      
                      {/* JSON output block */}
                      <pre className="text-gray-300 overflow-x-auto no-scrollbar">
                        {JSON.stringify(
                          Object.fromEntries(
                            Object.entries(log).filter(([k]) => k !== "timestamp")
                          ),
                          null,
                          2
                        )}
                      </pre>
                    </motion.div>
                  ))}
                </AnimatePresence>
              </div>
            </div>

            {/* Bottom developer CTA card */}
            <div className="p-6 bg-[#0b1120] border-t border-white/5 flex flex-wrap gap-4 items-center justify-between">
              <span className="text-xs text-gray-400 font-medium">Ready to deploy high-voltage APIs?</span>
              <a 
                href="#"
                className="btn-neon-green px-6 py-2.5 rounded-xl text-xs font-bold tracking-wider font-orbitron uppercase text-glow-green"
              >
                Inspect API Docs
              </a>
            </div>

          </div>

        </div>

      </div>
    </section>
  );
}
