"use client";

import React from "react";
import { motion } from "framer-motion";
import { Brain, Cpu, Database, Eye, RefreshCw, BarChart2 } from "lucide-react";

export default function EnergyIntelligence() {
  const cards = [
    {
      title: "AI Load Balancing",
      desc: "Dynamically paces electrical current outputs per connector gun depending on local grid stress parameters in real-time.",
      icon: Cpu,
      color: "from-cyan-500 to-blue-600",
      glow: "glow-border-blue",
    },
    {
      title: "Dynamic Pricing",
      desc: "Tunes charging tariffs dynamically, offering cheap slots during off-peak hours and adjusting cost factors during spike demand cycles.",
      icon: RefreshCw,
      color: "from-[#00ffb2] to-emerald-600",
      glow: "glow-border-green",
    },
    {
      title: "Smart Grid Routing",
      desc: "Forwards vehicle power needs to nearby active battery storage slots, decreasing overall power substation loads.",
      icon: Database,
      color: "from-purple-500 to-indigo-600",
      glow: "glow-border-purple",
    },
    {
      title: "Predictive Maintenance",
      desc: "Triggers remote diagnostics algorithms using ML patterns to capture cooling leakages or hardware spikes before fault events occur.",
      icon: Eye,
      color: "from-red-500 to-rose-600",
      glow: "box-shadow: 0 0 15px rgba(239, 68, 68, 0.2)",
    },
    {
      title: "Carbon Optimization",
      desc: "Prioritizes delivering clean solar/wind generated electricity to connected EVs to maximize green carbon offset metrics.",
      icon: BarChart2,
      color: "from-cyan-500 to-[#00ffb2]",
      glow: "glow-border-green",
    },
  ];

  return (
    <section id="technology" className="relative py-24 bg-[#050816] overflow-hidden">
      <div className="absolute inset-0 cyber-grid-dense opacity-15 pointer-events-none" />
      
      <div className="max-w-7xl mx-auto px-6 relative z-10">
        
        {/* Section Title */}
        <div className="text-center max-w-3xl mx-auto mb-20">
          <span className="text-xs font-bold uppercase tracking-widest text-[#00ffb2] font-orbitron flex items-center justify-center space-x-2">
            <Brain className="w-4 h-4 animate-pulse mr-1" />
            <span>NEURAL GRID BALANCING</span>
          </span>
          <h2 className="text-3xl md:text-5xl font-black uppercase font-orbitron mt-3 tracking-tight">AI Energy Intelligence</h2>
          <p className="text-gray-400 mt-4 text-sm md:text-base">
            Hyperion utilizes machine learning pipelines to stabilize high-voltage grids, manage station parameters, and allocate green power grids.
          </p>
        </div>

        {/* Layout Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          
          {/* Left Column: Interactive Neural Network Visualizer */}
          <div className="lg:col-span-5 h-[300px] md:h-[420px] glass-card rounded-3xl border border-white/5 relative overflow-hidden flex items-center justify-center bg-radial-gradient from-transparent to-[#050816]">
            
            {/* Projector Glow */}
            <div className="absolute w-44 h-44 rounded-full bg-cyan-500/5 blur-3xl animate-pulse pointer-events-none" />

            {/* Neural Connections Map SVG */}
            <svg className="absolute inset-0 w-full h-full opacity-50" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 400">
              {/* Computational Paths */}
              <g stroke="rgba(0, 255, 178, 0.2)" strokeWidth="1" fill="none">
                <line x1="200" y1="200" x2="100" y2="100" />
                <line x1="200" y1="200" x2="300" y2="100" />
                <line x1="200" y1="200" x2="100" y2="300" />
                <line x1="200" y1="200" x2="300" y2="300" />
                
                <line x1="100" y1="100" x2="50" y2="200" />
                <line x1="300" y1="100" x2="350" y2="200" />
                <line x1="100" y1="300" x2="50" y2="200" />
                <line x1="300" y1="300" x2="350" y2="200" />
              </g>

              {/* Pulsing energy particles */}
              <circle cx="200" cy="200" r="10" fill="#00ffb2" opacity="0.3">
                <animate attributeName="r" values="6;16;6" dur="3s" repeatCount="indefinite" />
              </circle>
              <circle cx="200" cy="200" r="5" fill="#00ffb2" />

              {/* Surrounding Nodes */}
              {[
                { x: 100, y: 100, color: "#00d1ff" },
                { x: 300, y: 100, color: "#7b61ff" },
                { x: 100, y: 300, color: "#7b61ff" },
                { x: 300, y: 300, color: "#00ffb2" },
                { x: 50, y: 200, color: "#00ffb2" },
                { x: 350, y: 200, color: "#00d1ff" },
              ].map((node, nIdx) => (
                <g key={nIdx}>
                  <circle cx={node.x} cy={node.y} r="8" fill={node.color} opacity="0.2">
                    <animate attributeName="r" values="5;10;5" dur="2s" repeatCount="indefinite" />
                  </circle>
                  <circle cx={node.x} cy={node.y} r="3.5" fill={node.color} />
                </g>
              ))}
            </svg>

            {/* Central glowing indicator overlay */}
            <div className="absolute flex flex-col items-center">
              <span className="text-xs font-mono text-cyan-400 font-bold tracking-widest">[ NEURAL COMPILER ]</span>
              <span className="text-[10px] font-mono text-gray-500 uppercase font-bold tracking-wider mt-1">GRID DEVIATIONS: 0.04%</span>
            </div>
          </div>

          {/* Right Column: AI Feature Cards List */}
          <div className="lg:col-span-7 grid grid-cols-1 sm:grid-cols-2 gap-6">
            {cards.map((card, idx) => {
              const Icon = card.icon;
              return (
                <motion.div
                  key={idx}
                  initial={{ opacity: 0, y: 30 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.6, delay: idx * 0.1 }}
                  className={`glass-card p-6 rounded-2xl border border-white/5 group hover:border-[#00ffb2]/30 flex flex-col justify-between`}
                >
                  <div>
                    <div className="flex items-center justify-between mb-4">
                      <div className="p-2.5 bg-white/5 rounded-xl border border-white/10 text-glow-green text-[#00ffb2]">
                        <Icon className="w-5 h-5" />
                      </div>
                      <span className="text-[9px] font-mono text-gray-500 uppercase font-bold tracking-widest">
                        SYS MODULE 0{idx + 1}
                      </span>
                    </div>
                    <h3 className="text-sm font-extrabold uppercase tracking-widest text-white font-orbitron">
                      {card.title}
                    </h3>
                    <p className="text-xs text-gray-400 mt-2 leading-relaxed">
                      {card.desc}
                    </p>
                  </div>
                </motion.div>
              );
            })}
          </div>

        </div>

      </div>
    </section>
  );
}
