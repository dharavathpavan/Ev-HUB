"use client";

import React, { useState, useEffect } from "react";
import { motion } from "framer-motion";
import { Landmark, TrendingUp, Truck, BatteryCharging, ShieldAlert, CheckCircle2 } from "lucide-react";

export default function VendorFleet() {
  const [activeVehicles, setActiveVehicles] = useState(14);
  const [vendorRevenue, setVendorRevenue] = useState(48210);
  const [systemUptime, setSystemUptime] = useState(99.98);

  useEffect(() => {
    const timer = setInterval(() => {
      // Slight telemetry fluctuations
      setActiveVehicles((prev) => {
        const delta = Math.random() > 0.5 ? 1 : -1;
        return Math.max(10, Math.min(25, prev + delta));
      });
      setVendorRevenue((prev) => prev + Math.floor(Math.random() * 4) + 1);
      setSystemUptime((prev) => +(99.95 + Math.random() * 0.04).toFixed(2));
    }, 1500);
    return () => clearInterval(timer);
  }, []);

  return (
    <section id="vendors" className="relative py-24 bg-[#050816] overflow-hidden">
      <div className="absolute inset-0 cyber-grid-dense opacity-20 pointer-events-none" />
      
      <div className="max-w-7xl mx-auto px-6 relative z-10">
        
        {/* Title */}
        <div className="max-w-3xl mb-16">
          <span className="text-xs font-bold uppercase tracking-widest text-[#00ffb2] font-orbitron">ENTERPRISE SOLUTIONS</span>
          <h2 className="text-3xl md:text-5xl font-black uppercase font-orbitron mt-3 tracking-tight">CPO & Fleet Workspaces</h2>
          <p className="text-gray-400 mt-4 text-sm md:text-base">
            Scale your business using dedicated vendor analytics or coordinate massive corporate EV fleets using instant payment splits.
          </p>
        </div>

        {/* Side-by-Side Dashboard Layout */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
          
          {/* Left Column: Vendor Analytics Dashboard */}
          <div className="glass-panel p-8 rounded-3xl border border-cyan-500/10 flex flex-col justify-between h-full hover:border-cyan-500/20 transition-all duration-300">
            <div>
              <div className="flex justify-between items-center border-b border-white/5 pb-4 mb-6">
                <div className="flex items-center space-x-3">
                  <Landmark className="w-5 h-5 text-[#00d1ff] animate-pulse" />
                  <span className="text-white font-bold font-orbitron tracking-widest text-xs uppercase">CPO OPERATOR HUB</span>
                </div>
                <span className="text-[9px] font-mono text-cyan-400 border border-cyan-500/30 px-2 py-0.5 rounded">90% PAYOUT RATE</span>
              </div>

              {/* Earnings metrics row */}
              <div className="grid grid-cols-2 gap-4 mb-8">
                <div className="p-4 bg-white/2 rounded-xl border border-white/5 flex flex-col justify-between">
                  <span className="text-gray-500 text-[10px] uppercase font-bold tracking-wider">Gross Earnings</span>
                  <span className="text-xl font-bold font-orbitron text-white mt-4">${vendorRevenue.toLocaleString()}</span>
                </div>
                <div className="p-4 bg-white/2 rounded-xl border border-white/5 flex flex-col justify-between">
                  <span className="text-gray-500 text-[10px] uppercase font-bold tracking-wider">Vendor Net (90%)</span>
                  <span className="text-xl font-bold font-orbitron text-[#00ffb2]">${Math.floor(vendorRevenue * 0.9).toLocaleString()}</span>
                </div>
              </div>

              {/* Specs detailed ticks */}
              <div className="space-y-3 font-mono text-xs mb-8">
                {[
                  { label: "Platform Commission (10%)", val: `$${Math.floor(vendorRevenue * 0.1).toLocaleString()}`, color: "text-purple-400" },
                  { label: "Active Station Cabinets", val: "14 Deployed", color: "text-white" },
                  { label: "Monthly Utilization Rate", val: "48.2%", color: "text-[#00ffb2]" },
                  { label: "Bank Payout Cycle", val: "Daily (Instant Settlement)", color: "text-cyan-400" },
                ].map((spec, idx) => (
                  <div key={idx} className="flex justify-between items-center py-2.5 border-b border-white/5">
                    <span className="text-gray-500 font-bold uppercase">{spec.label}</span>
                    <span className={`font-bold ${spec.color}`}>{spec.val}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Glowing Action Button */}
            <a 
              href="http://localhost:8080/#/vendor-portal" 
              target="_blank"
              rel="noopener noreferrer"
              className="w-full py-4 text-center btn-neon-blue rounded-xl text-xs font-extrabold uppercase tracking-widest font-orbitron text-glow-blue"
            >
              Access Vendor Dashboard
            </a>
          </div>

          {/* Right Column: Fleet Management Dashboard */}
          <div className="glass-panel p-8 rounded-3xl border border-purple-500/10 flex flex-col justify-between h-full hover:border-purple-500/20 transition-all duration-300">
            <div>
              <div className="flex justify-between items-center border-b border-white/5 pb-4 mb-6">
                <div className="flex items-center space-x-3">
                  <Truck className="w-5 h-5 text-[#7b61ff] animate-bounce" />
                  <span className="text-white font-bold font-orbitron tracking-widest text-xs uppercase">FLEET ENTERPRISE CONSOLE</span>
                </div>
                <span className="text-[9px] font-mono text-[#7b61ff] border border-purple-500/30 px-2 py-0.5 rounded">FLEET PORTAL</span>
              </div>

              {/* Fleet status cards row */}
              <div className="grid grid-cols-2 gap-4 mb-8">
                <div className="p-4 bg-white/2 rounded-xl border border-white/5 flex flex-col justify-between">
                  <span className="text-gray-500 text-[10px] uppercase font-bold tracking-wider">Active Vehicles</span>
                  <span className="text-xl font-bold font-orbitron text-white mt-4">{activeVehicles} Transit</span>
                </div>
                <div className="p-4 bg-white/2 rounded-xl border border-white/5 flex flex-col justify-between">
                  <span className="text-gray-500 text-[10px] uppercase font-bold tracking-wider">Total Power Delivered</span>
                  <span className="text-xl font-bold font-orbitron text-cyan-400 mt-4">12,450 kWh</span>
                </div>
              </div>

              {/* Specs detailed ticks */}
              <div className="space-y-3 font-mono text-xs mb-8">
                {[
                  { label: "Active Dispatch Vehicles", val: `${activeVehicles} Delivery Trucks`, color: "text-[#00ffb2]" },
                  { label: "Pre-Auth Fleet Limit", val: "$1,200.00 Daily Buffer", color: "text-white" },
                  { label: "Grid Uptime SLA", val: `${systemUptime}% Guaranteed`, color: "text-cyan-400" },
                  { label: "Fleet RFID Card Keys", val: "42 Activated Keys", color: "text-white" },
                ].map((spec, idx) => (
                  <div key={idx} className="flex justify-between items-center py-2.5 border-b border-white/5">
                    <span className="text-gray-500 font-bold uppercase">{spec.label}</span>
                    <span className={`font-bold ${spec.color}`}>{spec.val}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Glowing Action Button */}
            <a 
              href="http://localhost:8080/#/fleet" 
              target="_blank"
              rel="noopener noreferrer"
              className="w-full py-4 text-center btn-neon-green rounded-xl text-xs font-extrabold uppercase tracking-widest font-orbitron text-glow-green"
            >
              Coordinate Corporate Fleet
            </a>
          </div>

        </div>

      </div>
    </section>
  );
}
