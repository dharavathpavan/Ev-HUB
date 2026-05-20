"use client";

import React, { useState, useEffect } from "react";
import { Canvas } from "@react-three/fiber";
import { OrbitControls } from "@react-three/drei";
import { motion, AnimatePresence } from "framer-motion";
import { Smartphone, QrCode, CreditCard, Compass, BarChart3, BellRing } from "lucide-react";
import SmartphoneModel from "./3d/SmartphoneModel";

export default function MobileApp() {
  const [activeScreen, setActiveScreen] = useState(0);

  const screens = [
    {
      title: "Realtime Charger Map",
      icon: Compass,
      desc: "Instant geolocation routing directing you to available 450 kW highway ultra-fast hubs and real-time bay occupancies.",
      mockup: (
        <div className="relative w-full h-full bg-[#0b1120] p-4 flex flex-col justify-between text-xs font-mono">
          <div className="flex justify-between items-center border-b border-white/5 pb-2">
            <span className="font-bold text-white">MAP NAVIGATOR</span>
            <span className="text-[10px] text-[#00d1ff]">GPS ACTIVE</span>
          </div>
          <div className="flex-1 flex flex-col justify-center items-center space-y-4">
            <div className="w-24 h-24 rounded-full border border-cyan-500/20 flex items-center justify-center relative animate-pulse">
              <div className="absolute w-2 h-2 bg-[#00ffb2] rounded-full animate-ping" />
              <div className="w-2.5 h-2.5 bg-[#00ffb2] rounded-full" />
            </div>
            <div className="text-center">
              <div className="font-bold text-white">Downtown Hub #04</div>
              <div className="text-[10px] text-gray-500 mt-1">2/4 Bays Available • 1.2 Miles</div>
            </div>
          </div>
        </div>
      ),
    },
    {
      title: "QR Connect Scan",
      icon: QrCode,
      desc: "Scan the physical high-voltage QR code sticker on the selected charging gun to instantly initiate the pre-auth handshake.",
      mockup: (
        <div className="relative w-full h-full bg-[#0b1120] p-4 flex flex-col justify-between text-xs font-mono">
          <div className="flex justify-between items-center border-b border-white/5 pb-2">
            <span className="font-bold text-white">QR SCANNER</span>
            <span className="text-[10px] text-purple-400">READY</span>
          </div>
          <div className="flex-1 flex flex-col justify-center items-center space-y-3">
            <div className="w-28 h-28 border-2 border-dashed border-[#7b61ff] rounded-xl flex items-center justify-center p-2">
              <QrCode className="w-20 h-20 text-[#7b61ff] animate-pulse" />
            </div>
            <div className="text-[10px] text-center text-gray-500">ALIGN QR CODE WITHIN BOUNDS</div>
          </div>
        </div>
      ),
    },
    {
      title: "Digital Payment Payout",
      icon: CreditCard,
      desc: "Fast payments via UPI, Google Pay, Apple Pay, or credit cards, utilizing instant wallet settlements and automatic refunds.",
      mockup: (
        <div className="relative w-full h-full bg-[#0b1120] p-4 flex flex-col justify-between text-xs font-mono">
          <div className="flex justify-between items-center border-b border-white/5 pb-2">
            <span className="font-bold text-white">CREDIT WALLET</span>
            <span className="text-[10px] text-[#00ffb2]">SECURE</span>
          </div>
          <div className="flex-1 flex flex-col justify-center space-y-4">
            <div className="p-4 rounded-xl border border-white/5 bg-white/2 flex flex-col justify-between h-24">
              <div className="text-gray-500 text-[10px] uppercase font-bold tracking-wider">Hyperion Credits</div>
              <div className="text-xl font-bold font-orbitron text-[#00ffb2]">$150.00</div>
            </div>
            <button className="w-full py-2 bg-gradient-to-r from-cyan-500 to-purple-600 rounded-lg text-[10px] font-bold text-white uppercase tracking-wider">
              Add Instant Credits
            </button>
          </div>
        </div>
      ),
    },
    {
      title: "Realtime Analytics",
      icon: BarChart3,
      desc: "Check power draw sparklines, temperature indicators, historical sessions, and carbon emission savings statistics.",
      mockup: (
        <div className="relative w-full h-full bg-[#0b1120] p-4 flex flex-col justify-between text-xs font-mono">
          <div className="flex justify-between items-center border-b border-white/5 pb-2">
            <span className="font-bold text-white">ANALYTICS</span>
            <span className="text-[10px] text-[#00d1ff]">UPDATED</span>
          </div>
          <div className="flex-1 flex flex-col justify-center space-y-3">
            <div className="flex justify-between">
              <span>POWER DELIVERED</span>
              <span className="text-[#00ffb2] font-bold">142 kWh</span>
            </div>
            <div className="flex justify-between">
              <span>CO2 OFFSET</span>
              <span className="text-cyan-400 font-bold">54.2 Kg</span>
            </div>
            <div className="w-full h-12 border border-cyan-500/10 rounded relative overflow-hidden bg-cyan-900/5">
              <div className="absolute bottom-0 w-full h-[60%] bg-[#00d1ff]/10 border-t border-[#00d1ff]/40 animate-pulse" />
            </div>
          </div>
        </div>
      ),
    },
  ];

  // Auto-cycle mobile app screens
  useEffect(() => {
    const timer = setInterval(() => {
      setActiveScreen((prev) => (prev + 1) % screens.length);
    }, 4500);
    return () => clearInterval(timer);
  }, [screens.length]);

  return (
    <section id="features" className="relative py-24 bg-[#050816] overflow-hidden">
      <div className="absolute inset-0 cyber-grid opacity-15 pointer-events-none" />
      
      <div className="max-w-7xl mx-auto px-6 relative z-10">
        
        {/* Heading */}
        <div className="text-center max-w-3xl mx-auto mb-20">
          <span className="text-xs font-bold uppercase tracking-widest text-[#00d1ff] font-orbitron">MOBILE WORKSPACE</span>
          <h2 className="text-3xl md:text-5xl font-black uppercase font-orbitron mt-3 tracking-tight">Hyperion Consumer App</h2>
          <p className="text-gray-400 mt-4 text-sm md:text-base">
            Provision charging guns, track live energy curves, trigger wallet refunds, and map routes right from your smartphone.
          </p>
        </div>

        {/* Layout Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          
          {/* Left Column: 3D Smartphone Viewport */}
          <div className="lg:col-span-6 h-[400px] md:h-[500px] glass-card rounded-3xl border border-white/5 relative overflow-hidden bg-gradient-to-t from-[#050816]/80 via-transparent to-[#050816]/80">
            <Canvas camera={{ position: [0, 0, 4.2], fov: 45 }}>
              <ambientLight intensity={0.8} />
              <pointLight position={[5, 5, 5]} intensity={1.5} color="#00ffb2" />
              <pointLight position={[-5, 3, -3]} intensity={1.0} color="#7b61ff" />
              <directionalLight position={[0, 4, 4]} intensity={1.2} color="#00d1ff" />
              
              <SmartphoneModel />
              
              <OrbitControls enableZoom={false} enablePan={false} />
            </Canvas>
          </div>

          {/* Right Column: Screen specs and cycling smartphone mockup */}
          <div className="lg:col-span-6 flex flex-col md:flex-row gap-8 items-center">
            
            {/* Screen details spec */}
            <div className="flex-1 space-y-6">
              <div className="space-y-3">
                {screens.map((scr, idx) => {
                  const Icon = scr.icon;
                  const isActive = activeScreen === idx;
                  return (
                    <button
                      key={idx}
                      onClick={() => setActiveScreen(idx)}
                      className={`w-full p-4 rounded-xl border flex items-center space-x-4 text-left transition-all duration-300 ${
                        isActive
                          ? "border-[#00ffb2] bg-[#00ffb2]/5 shadow-[0_0_15px_rgba(0,255,178,0.05)]"
                          : "border-white/5 bg-[#0b1120]/40 text-gray-400 hover:border-white/20 hover:text-white"
                      }`}
                    >
                      <div className={`p-2 rounded-lg border ${
                        isActive ? "border-[#00ffb2]/30 text-[#00ffb2]" : "border-white/10 text-gray-500"
                      }`}>
                        <Icon className="w-5 h-5" />
                      </div>
                      <div>
                        <h4 className={`text-sm font-bold font-orbitron uppercase ${isActive ? "text-white" : "text-gray-400"}`}>
                          {scr.title}
                        </h4>
                        {isActive && (
                          <p className="text-xs text-gray-400 mt-1 leading-relaxed">
                            {scr.desc}
                          </p>
                        )}
                      </div>
                    </button>
                  );
                })}
              </div>
            </div>

            {/* Cycling Interactive Smartphone Mockup Panel */}
            <div className="w-[200px] h-[380px] rounded-[32px] border-4 border-white/10 bg-[#050816] relative overflow-hidden shadow-[0_0_40px_rgba(0,209,255,0.1)] shrink-0">
              {/* Top notch */}
              <div className="absolute top-2 left-1/2 transform -translate-x-1/2 w-16 h-3.5 bg-white/10 rounded-full z-20 flex justify-center items-center">
                <div className="w-1.5 h-1.5 rounded-full bg-white/30" />
              </div>
              
              <AnimatePresence mode="wait">
                <motion.div
                  key={activeScreen}
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.95 }}
                  transition={{ duration: 0.3 }}
                  className="w-full h-full pt-6"
                >
                  {screens[activeScreen].mockup}
                </motion.div>
              </AnimatePresence>
            </div>

          </div>

        </div>

      </div>
    </section>
  );
}
