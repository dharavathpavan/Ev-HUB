"use client";

import React from "react";
import { Canvas, useFrame } from "@react-three/fiber";
import { OrbitControls } from "@react-three/drei";
import { motion } from "framer-motion";
import EvChargerModel from "./3d/EvChargerModel";
import CityGrid from "./3d/CityGrid";
import { ArrowRight, Globe, ShieldCheck } from "lucide-react";

// Interactive camera mouse-parallax movement
function CameraRig() {
  useFrame((state) => {
    state.camera.position.x += (state.pointer.x * 3 - state.camera.position.x) * 0.05;
    state.camera.position.y += (state.pointer.y * 2 + 1 - state.camera.position.y) * 0.05;
    state.camera.lookAt(0, 0.4, 0);
  });
  return null;
}

export default function Hero() {
  return (
    <section className="relative w-full min-h-screen bg-[#050816] flex items-center justify-center overflow-hidden pt-20">
      {/* Cyber Grid Background Plate */}
      <div className="absolute inset-0 cyber-grid opacity-30 pointer-events-none" />
      <div className="absolute inset-0 bg-gradient-to-t from-[#050816] via-transparent to-[#050816] pointer-events-none z-10" />

      {/* Fullscreen 3D Canvas backdrop */}
      <div className="absolute inset-0 w-full h-full z-0">
        <Canvas
          camera={{ position: [0, 1.2, 5.5], fov: 55 }}
          dpr={[1, 2]}
        >
          <color attach="background" args={["#050816"]} />
          <fog attach="fog" args={["#050816", 4, 12]} />
          
          <ambientLight intensity={0.5} />
          <pointLight position={[10, 10, 10]} intensity={1.5} color="#00d1ff" />
          <pointLight position={[-10, 5, -5]} intensity={1.0} color="#7b61ff" />
          <directionalLight position={[0, 5, 5]} intensity={1.2} color="#00ffb2" />
          
          <CityGrid />
          <EvChargerModel />
          
          <CameraRig />
        </Canvas>
      </div>

      {/* Hero Content Overlay */}
      <div className="relative max-w-7xl mx-auto px-6 w-full h-full z-20 flex flex-col justify-center items-start pt-12 md:pt-20">
        {/* Cinematic Announcement Banner */}
        <motion.div 
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.2 }}
          className="flex items-center space-x-2 px-4 py-1.5 rounded-full glass-panel border border-[#00d1ff]/20 mb-6"
        >
          <span className="flex h-2 w-2 relative">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#00ffb2] opacity-75"></span>
            <span className="relative inline-flex rounded-full h-2 w-2 bg-[#00ffb2]"></span>
          </span>
          <span className="text-xs font-bold uppercase tracking-widest text-cyan-400 font-orbitron">
            GLOBAL CHARGING PLATFORM V2.0
          </span>
        </motion.div>

        {/* Headline block */}
        <motion.h1 
          initial={{ opacity: 0, x: -50 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 1.0, ease: [0.16, 1, 0.3, 1], delay: 0.4 }}
          className="text-4xl sm:text-6xl md:text-8xl font-black tracking-tight leading-none uppercase font-orbitron max-w-4xl"
        >
          Powering The <br />
          <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#00d1ff] via-[#00ffb2] to-[#7b61ff] text-glow-blue">
            Future
          </span>{" "}
          Of EV Mobility
        </motion.h1>

        {/* Subtitle */}
        <motion.p 
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.6 }}
          className="text-gray-400 text-lg md:text-xl font-medium max-w-xl mt-6 tracking-wide"
        >
          Realtime electric charging ecosystem built for ultra-fast networks, intelligent CPOs, and smart city microgrids.
        </motion.p>

        {/* Action Button cluster */}
        <motion.div 
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.8 }}
          className="flex flex-wrap gap-4 mt-10 w-full sm:w-auto"
        >
          <a
            href="http://localhost:8080/#/dashboard"
            target="_blank"
            rel="noopener noreferrer" 
            className="btn-neon-green px-8 py-4 rounded-full text-sm font-extrabold tracking-wider text-white uppercase font-orbitron flex items-center space-x-2 text-glow-green"
          >
            <span>Start Charging</span>
            <ArrowRight className="w-4 h-4" />
          </a>
          
          <a 
            href="#network"
            className="btn-neon-blue px-8 py-4 rounded-full text-sm font-extrabold tracking-wider text-white uppercase font-orbitron flex items-center space-x-2 text-glow-blue"
          >
            <Globe className="w-4 h-4" />
            <span>Explore Network</span>
          </a>

          <a 
            href="http://localhost:8080/#/vendor-portal"
            target="_blank"
            rel="noopener noreferrer" 
            className="px-8 py-4 bg-transparent border border-white/10 rounded-full text-sm font-bold tracking-wider text-gray-300 hover:border-white/30 hover:text-white transition-all duration-300 flex items-center space-x-2"
          >
            <ShieldCheck className="w-4 h-4 text-cyan-400" />
            <span>Become Vendor</span>
          </a>
        </motion.div>

        {/* Bottom Feature Stats Row */}
        <motion.div 
          initial={{ opacity: 0 }}
          animate={{ opacity: 0.6 }}
          transition={{ duration: 1.0, delay: 1.2 }}
          className="mt-16 border-t border-white/10 pt-6 flex flex-wrap gap-12 w-full max-w-4xl"
        >
          <div>
            <div className="text-2xl font-bold font-orbitron text-white">99.98%</div>
            <div className="text-xs text-gray-500 font-bold uppercase tracking-widest mt-1">Cabinet Uptime</div>
          </div>
          <div>
            <div className="text-2xl font-bold font-orbitron text-white">&lt;150ms</div>
            <div className="text-xs text-gray-500 font-bold uppercase tracking-widest mt-1">OCPP Latency</div>
          </div>
          <div>
            <div className="text-2xl font-bold font-orbitron text-white">450 kW</div>
            <div className="text-xs text-gray-500 font-bold uppercase tracking-widest mt-1">Max Power Draw</div>
          </div>
        </motion.div>
      </div>

      {/* Floating Volumetric Energy Dust Particles */}
      <div className="absolute bottom-10 left-1/2 transform -translate-x-1/2 z-20 flex flex-col items-center animate-bounce">
        <span className="text-[10px] uppercase font-bold tracking-widest text-cyan-400/60 font-orbitron mb-2">SCROLL DOWN</span>
        <div className="w-1.5 h-10 rounded-full bg-gradient-to-b from-[#00d1ff] to-transparent opacity-80" />
      </div>
    </section>
  );
}
