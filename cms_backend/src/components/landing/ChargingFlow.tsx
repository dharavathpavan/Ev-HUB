"use client";

import React, { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Cable, CreditCard, Zap, BarChart3, RotateCcw } from "lucide-react";

export default function ChargingFlow() {
  const [activeStep, setActiveStep] = useState(0);

  const steps = [
    {
      title: "Plug In",
      subtitle: "Connect Vehicle",
      icon: Cable,
      glow: "border-[#00d1ff] text-[#00d1ff] bg-[#00d1ff]/5",
      color: "#00d1ff",
      desc: "Connect your electric vehicle to our Hyperion cabinet connector. The physical cable locks automatically with high-voltage physical barriers engaged, communicating telemetry parameters via OCPP protocol in milliseconds.",
      visual: (
        <div className="relative w-full h-full flex items-center justify-center">
          {/* Concentric rotating glowing electric pulses */}
          <div className="absolute w-32 h-32 rounded-full border border-cyan-500/20 animate-spin-slow" />
          <div className="absolute w-24 h-24 rounded-full border border-dashed border-cyan-500/40 animate-spin" />
          <div className="p-6 bg-cyan-900/10 rounded-full border border-cyan-500/30 text-[#00d1ff] animate-float relative">
            <Cable className="w-16 h-16" />
            <div className="absolute -top-1 -right-1 w-4 h-4 bg-[#00ffb2] rounded-full animate-ping" />
          </div>
          <span className="absolute bottom-4 text-xs font-mono text-cyan-400/70">[ OCPP HANDSHAKE ACTIVE ]</span>
        </div>
      ),
    },
    {
      title: "UPI / Card",
      subtitle: "Instant Pre-Auth",
      icon: CreditCard,
      glow: "border-[#7b61ff] text-[#7b61ff] bg-[#7b61ff]/5",
      color: "#7b61ff",
      desc: "Authorize the charging session via UPI, net banking, or debit/credit wallets. The system locks a pre-authorized security deposit in escrow (releasing it immediately when the charging process terminates).",
      visual: (
        <div className="relative w-full h-full flex items-center justify-center">
          <div className="absolute w-36 h-36 rounded-full bg-[#7b61ff]/5 animate-pulse" />
          <div className="p-6 bg-purple-900/10 rounded-3xl border border-[#7b61ff]/40 text-[#7b61ff] relative w-48 h-32 flex flex-col justify-between">
            <div className="flex justify-between items-center">
              <CreditCard className="w-8 h-8" />
              <span className="text-[10px] font-mono border border-[#7b61ff]/30 px-2 py-0.5 rounded">UPI LINKED</span>
            </div>
            <div>
              <div className="text-xs font-mono opacity-60">PRE-AUTH SECURED</div>
              <div className="text-lg font-bold font-orbitron text-white">$150.00</div>
            </div>
          </div>
        </div>
      ),
    },
    {
      title: "Charge",
      subtitle: "Hyper-Transfer",
      icon: Zap,
      glow: "border-[#00ffb2] text-[#00ffb2] bg-[#00ffb2]/5",
      color: "#00ffb2",
      desc: "Watch high-density carbon-neutral energy transfer safely into your battery pack. The cabinet leverages real-time active cooling systems to maintain a constant 450 kW speed without causing grid overheating.",
      visual: (
        <div className="relative w-full h-full flex items-center justify-center">
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="w-48 h-48 rounded-full border border-[#00ffb2]/10 border-t-[#00ffb2]/60 animate-spin" />
          </div>
          <div className="p-8 bg-[#00ffb2]/5 rounded-full border border-[#00ffb2]/30 text-[#00ffb2] animate-pulse">
            <Zap className="w-16 h-16" />
          </div>
          <div className="absolute flex flex-col items-center">
            <span className="text-xs font-bold font-orbitron text-white">450 kW</span>
            <span className="text-[10px] font-mono text-[#00ffb2]/70 mt-1">CHARGING ACTIVE</span>
          </div>
        </div>
      ),
    },
    {
      title: "Monitor",
      subtitle: "Digital Twin",
      icon: BarChart3,
      glow: "border-[#00d1ff] text-[#00d1ff] bg-[#00d1ff]/5",
      color: "#00d1ff",
      desc: "Track battery state of charge (SoC), active voltage limits, real-time pricing distributions, and environmental metrics directly on the mobile app or within the web dashboard using a live websocket stream.",
      visual: (
        <div className="relative w-full h-full flex flex-col items-center justify-center px-6">
          <div className="w-full glass-panel p-4 rounded-xl border border-white/5 font-mono text-[10px] space-y-2">
            <div className="flex justify-between border-b border-white/5 pb-1">
              <span>VOLTAGE</span>
              <span className="text-cyan-400">800V DC</span>
            </div>
            <div className="flex justify-between border-b border-white/5 pb-1">
              <span>CURRENT</span>
              <span className="text-[#00ffb2]">560A</span>
            </div>
            <div className="flex justify-between border-b border-white/5 pb-1">
              <span>TEMP</span>
              <span className="text-amber-400">34.2 °C</span>
            </div>
            <div className="flex justify-between">
              <span>SoC STATE</span>
              <span className="text-[#00ffb2] font-bold">84%</span>
            </div>
          </div>
        </div>
      ),
    },
    {
      title: "Refund",
      subtitle: "Instant Payout",
      icon: RotateCcw,
      glow: "border-red-400 text-red-400 bg-red-400/5",
      color: "#f87171",
      desc: "Session concludes seamlessly when your battery reaches its threshold. The unused portion of your pre-authorized security deposit returns directly to your bank account via UPI in less than 3 seconds.",
      visual: (
        <div className="relative w-full h-full flex items-center justify-center">
          <div className="absolute w-28 h-28 bg-red-400/5 rounded-full animate-pulse" />
          <div className="p-6 bg-red-900/10 rounded-full border border-red-400/30 text-red-400 relative">
            <RotateCcw className="w-12 h-12" />
          </div>
          <div className="absolute mt-24 text-[10px] font-mono text-red-400 border border-red-400/20 px-2 py-0.5 rounded bg-red-900/20">
            REFUNDED: $112.50
          </div>
        </div>
      ),
    },
  ];

  return (
    <section id="technology" className="relative py-24 bg-[#050816] overflow-hidden">
      <div className="absolute inset-0 cyber-grid opacity-15 pointer-events-none" />
      
      <div className="max-w-7xl mx-auto px-6 relative z-10">
        
        {/* Section Heading */}
        <div className="max-w-3xl mb-16">
          <span className="text-xs font-bold uppercase tracking-widest text-[#00d1ff] font-orbitron">THE HYPERION JOURNEY</span>
          <h2 className="text-3xl md:text-5xl font-black uppercase font-orbitron mt-3 tracking-tight">Interactive Charging Journey</h2>
          <p className="text-gray-400 mt-4 text-sm md:text-base">
            From physical connection to instant billing settlements, our platform integrates standard banking transactions and remote telemetry logs in a seamless loop.
          </p>
        </div>

        {/* Timeline Layout */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-12 items-center">
          
          {/* Left Column: Horizontal timeline nodes selector */}
          <div className="lg:col-span-2 flex flex-col space-y-4">
            
            {/* Horizontal Track vector */}
            <div className="relative flex justify-between items-center mb-8 border-b border-white/5 pb-8 overflow-x-auto no-scrollbar">
              {steps.map((step, idx) => {
                const Icon = step.icon;
                const isActive = activeStep === idx;
                
                return (
                  <button 
                    key={idx}
                    onClick={() => setActiveStep(idx)}
                    className="flex flex-col items-center min-w-[100px] focus:outline-none transition-all duration-300 relative group"
                  >
                    {/* Ring/Icon */}
                    <div 
                      className={`w-14 h-14 rounded-full border-2 flex items-center justify-center transition-all duration-500 relative z-10 ${
                        isActive 
                          ? `scale-115 ${step.glow}` 
                          : "border-white/10 text-gray-500 bg-[#0b1120] group-hover:border-white/30 group-hover:text-white"
                      }`}
                      style={{ 
                        boxShadow: isActive ? `0 0 20px ${step.color}40` : "none" 
                      }}
                    >
                      <Icon className="w-5 h-5" />
                    </div>

                    {/* Step index label */}
                    <span className={`text-[10px] font-mono uppercase tracking-wider mt-4 ${
                      isActive ? "text-[#00ffb2] font-bold" : "text-gray-500"
                    }`}>
                      STAGE 0{idx + 1}
                    </span>

                    {/* Step Title */}
                    <span className={`text-xs font-bold font-orbitron mt-1 ${
                      isActive ? "text-white" : "text-gray-400 group-hover:text-white"
                    }`}>
                      {step.title}
                    </span>
                  </button>
                );
              })}
            </div>

            {/* Description details card of active step */}
            <div className="glass-card p-8 rounded-2xl border border-white/5 relative min-h-[220px] flex flex-col justify-center">
              <AnimatePresence mode="wait">
                <motion.div
                  key={activeStep}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: 20 }}
                  transition={{ duration: 0.3 }}
                >
                  <div className="flex items-center space-x-3 mb-4">
                    <div 
                      className="w-2 h-6 rounded-full" 
                      style={{ backgroundColor: steps[activeStep].color }}
                    />
                    <h3 className="text-xl font-bold font-orbitron uppercase text-white">
                      {steps[activeStep].title} — <span className="text-gray-400">{steps[activeStep].subtitle}</span>
                    </h3>
                  </div>
                  <p className="text-gray-300 tracking-wide leading-relaxed text-sm md:text-base">
                    {steps[activeStep].desc}
                  </p>
                </motion.div>
              </AnimatePresence>
            </div>
          </div>

          {/* Right Column: Dynamic Holographic Visualization viewport */}
          <div className="glass-card p-6 h-[300px] md:h-[380px] rounded-3xl border border-white/5 flex items-center justify-center relative overflow-hidden bg-radial-gradient from-transparent to-[#050816]">
            {/* Holographic light projector base beam */}
            <div className="absolute bottom-0 w-32 h-[80%] bg-gradient-to-t from-cyan-500/10 via-transparent to-transparent clip-path-hologram pointer-events-none" />
            
            <AnimatePresence mode="wait">
              <motion.div 
                key={activeStep}
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.8 }}
                transition={{ duration: 0.4 }}
                className="w-full h-full flex items-center justify-center"
              >
                {steps[activeStep].visual}
              </motion.div>
            </AnimatePresence>
          </div>

        </div>

      </div>
    </section>
  );
}
