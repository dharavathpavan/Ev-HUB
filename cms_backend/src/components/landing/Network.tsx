"use client";

import React, { useEffect, useState, useRef } from "react";
import { motion, useInView } from "framer-motion";
import { Activity, ShieldAlert, Cpu, Award } from "lucide-react";

// Ticker component for counting numbers in real-time
function CountingTicker({ end, duration = 2, suffix = "" }: { end: number; duration?: number; suffix?: string }) {
  const [count, setCount] = useState(0);
  const ref = useRef(null);
  const inView = useInView(ref, { once: true });

  useEffect(() => {
    if (!inView) return;
    let start = 0;
    const increment = end / (duration * 60);
    const handle = setInterval(() => {
      start += increment;
      if (start >= end) {
        setCount(end);
        clearInterval(handle);
      } else {
        setCount(Math.floor(start));
      }
    }, 1000 / 60);
    return () => clearInterval(handle);
  }, [end, duration, inView]);

  return <span ref={ref}>{count.toLocaleString()}{suffix}</span>;
}

export default function Network() {
  const containerRef = useRef(null);
  const isInView = useInView(containerRef, { amount: 0.2 });

  return (
    <section id="network" ref={containerRef} className="relative py-24 bg-[#050816] overflow-hidden">
      {/* Dense grid background */}
      <div className="absolute inset-0 cyber-grid-dense opacity-20 pointer-events-none" />
      
      <div className="max-w-7xl mx-auto px-6 relative z-10">
        
        {/* Header Block */}
        <div className="text-center max-w-3xl mx-auto mb-20">
          <motion.span 
            initial={{ opacity: 0, y: 15 }}
            whileInView={{ opacity: 1, y: 0 }}
            className="text-xs font-bold uppercase tracking-widest text-[#00ffb2] font-orbitron"
          >
            HYPERION POWER MATRIX
          </motion.span>
          <motion.h2 
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="text-3xl md:text-5xl font-extrabold uppercase font-orbitron mt-3 tracking-tight"
          >
            Live Global Grid Infrastructure
          </motion.h2>
          <motion.p 
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="text-gray-400 mt-4 tracking-wide text-sm md:text-base"
          >
            Realtime telemetry monitoring active grid nodes, cabinet distributions, and clean carbon offsets dispensed.
          </motion.p>
        </div>

        {/* Map Visualizer Area */}
        <div className="relative w-full h-[350px] md:h-[500px] glass-card rounded-3xl overflow-hidden border border-white/5 mb-16">
          <div className="absolute inset-0 bg-radial-gradient from-transparent to-[#050816] pointer-events-none z-10" />
          
          {/* Animated SVG Network Vector Map */}
          <svg className="absolute inset-0 w-full h-full opacity-60" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 500">
            {/* Connected grid matrix nodes paths */}
            <g stroke="rgba(0, 209, 255, 0.15)" strokeWidth="1" fill="none">
              <path d="M 100 200 L 250 120 L 400 220 L 550 180 L 700 280 L 850 160" />
              <path d="M 250 120 L 350 320 L 550 180 L 620 380 L 850 160" />
              <path d="M 100 200 L 300 260 L 400 220 L 600 120 L 750 220 M 750 220 L 900 300" />
              <path d="M 300 260 L 500 390 L 700 280" />
            </g>

            {/* Pulsing energy particles along the paths */}
            <path d="M 100 200 L 250 120 L 400 220 L 550 180 L 700 280 L 850 160" fill="none" stroke="#00ffb2" strokeWidth="2" strokeDasharray="30, 250" strokeDashoffset="0">
              <animate attributeName="stroke-dashoffset" values="280;0" dur="8s" repeatCount="indefinite" />
            </path>
            <path d="M 250 120 L 350 320 L 550 180 L 620 380 L 850 160" fill="none" stroke="#7b61ff" strokeWidth="2" strokeDasharray="50, 300" strokeDashoffset="0">
              <animate attributeName="stroke-dashoffset" values="350;0" dur="10s" repeatCount="indefinite" />
            </path>

            {/* Glowing Map Hubs Nodes */}
            {[
              { cx: 100, cy: 200, label: "Seattle Node", color: "#00d1ff" },
              { cx: 250, cy: 120, label: "Chicago Core", color: "#00ffb2" },
              { cx: 400, cy: 220, label: "Austin Node", color: "#7b61ff" },
              { cx: 550, cy: 180, label: "Atlanta Core", color: "#00ffb2" },
              { cx: 700, cy: 280, label: "Boston Node", color: "#00d1ff" },
              { cx: 850, cy: 160, label: "New York Core", color: "#7b61ff" },
              { cx: 350, cy: 320, label: "Dallas Station", color: "#00d1ff" },
              { cx: 620, cy: 380, label: "Miami Station", color: "#00ffb2" },
              { cx: 300, cy: 260, label: "Denver Node", color: "#7b61ff" },
              { cx: 600, cy: 120, label: "Toronto Node", color: "#00d1ff" },
            ].map((node, idx) => (
              <g key={idx}>
                {/* Node Outer Pulsing Wave */}
                <circle cx={node.cx} cy={node.cy} r="12" fill={node.color} opacity="0.15">
                  <animate attributeName="r" values="8;18;8" dur="3s" repeatCount="indefinite" />
                  <animate attributeName="opacity" values="0.3;0;0.3" dur="3s" repeatCount="indefinite" />
                </circle>
                
                {/* Node Center Dot */}
                <circle cx={node.cx} cy={node.cy} r="4" fill={node.color} />
                
                {/* Label text */}
                <text x={node.cx} y={node.cy - 12} fill="#9ca3af" fontSize="9" fontWeight="bold" fontFamily="monospace" textAnchor="middle">
                  {node.label}
                </text>
              </g>
            ))}
          </svg>

          {/* Glowing bottom telemetry drawer panel overlay */}
          <div className="absolute bottom-6 left-6 right-6 z-20 flex flex-wrap gap-6 items-center justify-between p-6 glass-panel rounded-2xl border border-white/5">
            <div className="flex items-center space-x-3">
              <div className="w-3 h-3 rounded-full bg-[#00ffb2] animate-pulse" />
              <span className="text-xs font-bold uppercase tracking-widest text-[#00ffb2] font-orbitron">SYSTEM STATS: STABLE</span>
            </div>
            <div className="flex items-center space-x-6 text-xs text-gray-400 font-mono">
              <span>ACTIVE TRANSFERS: 4,124 kW</span>
              <span>OCPP PROTOCOL: V2.0.1</span>
              <span>GRID STRESS: NOMINAL (42%)</span>
            </div>
          </div>
        </div>

        {/* Live Statistics Cards Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {[
            { label: "Active Chargers", val: 12450, suf: "+", desc: "Global deployed hubs", icon: Cpu, color: "text-[#00d1ff]" },
            { label: "Sessions Dispensed", val: 1200000, suf: "", desc: "Successful vehicle power-ups", icon: Activity, color: "text-[#00ffb2]" },
            { label: "Connected Cities", val: 58, suf: "", desc: "Metropolitan smart grids", icon: Award, color: "text-[#7b61ff]" },
            { label: "Network Uptime", val: 98, suf: ".4%", desc: "Fault resilient hardware SLA", icon: ShieldAlert, color: "text-red-400" },
          ].map((card, i) => {
            const Icon = card.icon;
            return (
              <motion.div 
                key={i}
                initial={{ opacity: 0, y: 40 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6, delay: i * 0.1 }}
                className="glass-card p-8 rounded-2xl border border-white/5 group hover:border-[#00ffb2]/30 flex flex-col justify-between"
              >
                <div className="flex items-start justify-between">
                  <div className="p-3 bg-white/5 rounded-xl border border-white/10 group-hover:border-[#00ffb2]/20 transition-all duration-300">
                    <Icon className={`w-6 h-6 ${card.color}`} />
                  </div>
                  <span className="text-3xl font-black font-orbitron tracking-tight text-white group-hover:text-glow-green transition-colors duration-300">
                    <CountingTicker end={card.val} suffix={card.suf} />
                  </span>
                </div>
                <div className="mt-8">
                  <h4 className="text-sm font-extrabold uppercase tracking-widest text-white">{card.label}</h4>
                  <p className="text-xs text-gray-400 mt-1">{card.desc}</p>
                </div>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
