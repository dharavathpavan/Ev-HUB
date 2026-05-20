"use client";

import React, { useState, useEffect, useRef } from "react";
import { motion } from "framer-motion";
import { Gauge, Zap, BatteryCharging, DollarSign, RefreshCw, Server, AlertCircle } from "lucide-react";

export default function DashboardSection() {
  // Real-time statistics simulator
  const [soc, setSoc] = useState(42);
  const [kw, setKw] = useState(380.4);
  const [voltage, setVoltage] = useState(802.1);
  const [current, setCurrent] = useState(474.3);
  const [cost, setCost] = useState(12.45);
  const [temp, setTemp] = useState(32.8);
  const [timeRemaining, setTimeRemaining] = useState(18); // minutes
  const [logs, setLogs] = useState<string[]>([
    "OCPP socket remote connection established.",
    "Hardware authorization pre-auth: APPROVED.",
    "BMS handshake complete: charging parameters negotiated.",
  ]);

  const tickCount = useRef(0);

  useEffect(() => {
    const timer = setInterval(() => {
      // Increment battery State of Charge
      setSoc((prev) => {
        if (prev >= 100) return 42; // reset
        return prev + 1;
      });

      // Simulated jitter in telemetry
      setKw((prev) => +(prev + (Math.random() - 0.5) * 6).toFixed(1));
      setVoltage((prev) => +(prev + (Math.random() - 0.5) * 1.5).toFixed(1));
      setCurrent((prev) => +(prev + (Math.random() - 0.5) * 3).toFixed(1));
      setCost((prev) => +(prev + 0.08).toFixed(2));
      setTemp((prev) => +(prev + (Math.random() - 0.5) * 0.4).toFixed(1));

      // Periodically update time remaining
      tickCount.current += 1;
      if (tickCount.current % 12 === 0) {
        setTimeRemaining((prev) => (prev <= 1 ? 25 : prev - 1));
      }

      // Add random live operational alerts/logs
      if (Math.random() > 0.75) {
        const mockAlerts = [
          `Current output throttled slightly: grid demand buffer.`,
          `BMS dynamic temperature reading: ${temp.toFixed(1)} °C.`,
          `OCPP telemetry heartbeat accepted.`,
          `Cooling fluid pressure stabilized.`,
        ];
        const randomAlert = mockAlerts[Math.floor(Math.random() * mockAlerts.length)];
        setLogs((prev) => [randomAlert, ...prev.slice(0, 3)]);
      }

    }, 1200);

    return () => clearInterval(timer);
  }, [temp]);

  return (
    <section id="technology" className="relative py-24 bg-[#050816] overflow-hidden">
      <div className="absolute inset-0 cyber-grid-dense opacity-20 pointer-events-none" />
      
      <div className="max-w-7xl mx-auto px-6 relative z-10">
        
        {/* Header Section */}
        <div className="max-w-3xl mb-16">
          <span className="text-xs font-bold uppercase tracking-widest text-[#00ffb2] font-orbitron">INTELLIGENT TELEMETRY</span>
          <h2 className="text-3xl md:text-5xl font-black uppercase font-orbitron mt-3 tracking-tight">Realtime Operations Console</h2>
          <p className="text-gray-400 mt-4 text-sm md:text-base">
            Inspect our Tesla-inspired HUD dashboard tracking real-time charger telemetry metrics and active electrical transfer volumes.
          </p>
        </div>

        {/* Dashboard Frame Area */}
        <div className="relative w-full p-8 md:p-12 glass-panel rounded-3xl border border-cyan-500/10 shadow-[0_0_50px_rgba(0,209,255,0.05)] overflow-hidden">
          <div className="absolute inset-0 bg-radial-gradient from-transparent to-[#050816]/60 pointer-events-none" />
          
          {/* Top Bar inside HUD Console */}
          <div className="flex flex-wrap items-center justify-between gap-6 border-b border-cyan-500/15 pb-6 mb-8 font-mono text-xs">
            <div className="flex items-center space-x-3">
              <Server className="w-5 h-5 text-[#00d1ff] animate-pulse" />
              <span className="text-white font-bold tracking-widest uppercase font-orbitron">CABINET-HYP-DX400 // HUB-A1</span>
            </div>
            <div className="flex items-center space-x-6 text-gray-400">
              <span className="flex items-center space-x-2">
                <span className="w-2.5 h-2.5 bg-[#00ffb2] rounded-full animate-ping" />
                <span className="font-bold text-[#00ffb2]">WEBSOCKET: CONNECTED</span>
              </span>
              <span>SLOTS: 01 / 02 ACTIVE</span>
            </div>
          </div>

          {/* Main Grid inside HUD */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            
            {/* Left: Charging stats lists */}
            <div className="space-y-6">
              <h3 className="text-sm font-extrabold uppercase tracking-widest text-cyan-400 font-orbitron">SESSION TELEMETRY</h3>
              
              <div className="grid grid-cols-2 gap-4">
                {/* Cost card */}
                <div className="bg-white/3 rounded-xl border border-white/5 p-4 flex flex-col justify-between">
                  <div className="flex justify-between text-gray-500 text-[10px] font-bold uppercase tracking-wider">
                    <span>Active Cost</span>
                    <DollarSign className="w-3.5 h-3.5 text-[#00ffb2]" />
                  </div>
                  <div className="text-2xl font-bold font-orbitron text-white mt-4">${cost.toFixed(2)}</div>
                </div>

                {/* Energy Speed card */}
                <div className="bg-white/3 rounded-xl border border-white/5 p-4 flex flex-col justify-between">
                  <div className="flex justify-between text-gray-500 text-[10px] font-bold uppercase tracking-wider">
                    <span>Power Flow</span>
                    <Zap className="w-3.5 h-3.5 text-[#00d1ff]" />
                  </div>
                  <div className="text-2xl font-bold font-orbitron text-white mt-4">{kw.toFixed(1)} kW</div>
                </div>
              </div>

              {/* Specs detailed list with neon underlines */}
              <div className="space-y-3 font-mono text-xs">
                {[
                  { label: "Voltage Output", value: `${voltage.toFixed(1)} V DC`, color: "text-[#00d1ff]" },
                  { label: "Current Density", value: `${current.toFixed(1)} A`, color: "text-[#00ffb2]" },
                  { label: "BMS Temperature", value: `${temp.toFixed(1)} °C`, color: "text-amber-400" },
                  { label: "ETA to 100% SoC", value: `${timeRemaining} Mins`, color: "text-white" },
                ].map((spec, sIdx) => (
                  <div key={sIdx} className="flex justify-between items-center py-2.5 border-b border-white/5">
                    <span className="text-gray-500 font-bold uppercase">{spec.label}</span>
                    <span className={`font-bold ${spec.color}`}>{spec.value}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Center: Battery State of Charge Radial HUD Gauge */}
            <div className="flex flex-col items-center justify-center relative py-6">
              <div className="relative w-48 h-48 flex items-center justify-center">
                {/* Outer dynamic glowing ring */}
                <svg className="w-full h-full transform -rotate-90">
                  <circle cx="96" cy="96" r="82" stroke="rgba(255,255,255,0.03)" strokeWidth="6" fill="transparent" />
                  <circle 
                    cx="96" 
                    cy="96" 
                    r="82" 
                    stroke="#00ffb2" 
                    strokeWidth="6" 
                    fill="transparent" 
                    strokeDasharray={2 * Math.PI * 82}
                    strokeDashoffset={2 * Math.PI * 82 * (1 - soc / 100)}
                    strokeLinecap="round"
                    className="transition-all duration-1000 ease-out"
                    style={{ filter: "drop-shadow(0 0 8px #00ffb2)" }}
                  />
                </svg>
                
                {/* Center text details */}
                <div className="absolute flex flex-col items-center">
                  <BatteryCharging className="w-8 h-8 text-[#00ffb2] animate-bounce mb-1" />
                  <span className="text-4xl font-black font-orbitron text-white text-glow-green">{soc}%</span>
                  <span className="text-[9px] font-mono text-gray-500 uppercase font-bold tracking-widest mt-1">BATTERY CHARGE</span>
                </div>
              </div>
            </div>

            {/* Right: Live Web Socket Event Streams Console */}
            <div className="flex flex-col justify-between space-y-6">
              <div>
                <h3 className="text-sm font-extrabold uppercase tracking-widest text-[#7b61ff] font-orbitron mb-4">LIVE EVENT STREAM</h3>
                <div className="bg-[#0b1120]/60 p-4 rounded-xl border border-white/5 font-mono text-[10px] space-y-3 h-[180px] overflow-y-auto no-scrollbar">
                  {logs.map((log, idx) => (
                    <div key={idx} className="flex items-start space-x-2 text-gray-400">
                      <span className="text-cyan-400 font-bold shrink-0">&gt;&gt;</span>
                      <span className={idx === 0 ? "text-[#00ffb2]" : ""}>{log}</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Status footer inside HUD */}
              <div className="p-4 bg-[#7b61ff]/5 rounded-xl border border-[#7b61ff]/20 flex items-center space-x-3">
                <AlertCircle className="w-5 h-5 text-[#7b61ff]" />
                <span className="text-[10px] font-mono text-purple-300">
                  AI grid load-balancer actively dynamically pacing charging throttle speed: ACTIVE (MAX 450kW).
                </span>
              </div>
            </div>

          </div>

        </div>

      </div>
    </section>
  );
}
