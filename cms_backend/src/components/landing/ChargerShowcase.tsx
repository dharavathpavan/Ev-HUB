"use client";

import React, { useState, useRef } from "react";
import { Canvas, useFrame } from "@react-three/fiber";
import { OrbitControls, Float } from "@react-three/drei";
import { motion, AnimatePresence } from "framer-motion";
import { Info, Settings2, ShieldCheck, Zap, Gauge } from "lucide-react";
import { Mesh, Group } from "three";

// 3D Procedural Models
function ModelAC() {
  const meshRef = useRef<Group>(null);
  useFrame((state) => {
    const t = state.clock.getElapsedTime();
    if (meshRef.current) {
      meshRef.current.rotation.y = t * 0.35;
    }
  });

  return (
    <group ref={meshRef}>
      {/* Sleek AC Wallbox Column */}
      <mesh>
        <boxGeometry args={[0.7, 1.8, 0.3]} />
        <meshPhysicalMaterial color="#0b1120" roughness={0.1} metalness={0.9} />
      </mesh>
      {/* Glowing Neon Line */}
      <mesh position={[0, 0, 0.16]}>
        <cylinderGeometry args={[0.015, 0.015, 1.2, 8]} />
        <meshBasicMaterial color="#00ffb2" />
      </mesh>
      {/* Glass Pane Screen */}
      <mesh position={[0, 0.5, 0.16]}>
        <planeGeometry args={[0.5, 0.4]} />
        <meshPhysicalMaterial color="#00d1ff" transmission={0.9} transparent opacity={0.6} />
      </mesh>
    </group>
  );
}

function ModelDC() {
  const meshRef = useRef<Group>(null);
  useFrame((state) => {
    const t = state.clock.getElapsedTime();
    if (meshRef.current) {
      meshRef.current.rotation.y = t * 0.25;
    }
  });

  return (
    <group ref={meshRef}>
      {/* Massive DC Fast Cabinet */}
      <mesh>
        <boxGeometry args={[1.2, 2.2, 0.6]} />
        <meshPhysicalMaterial color="#0b1120" roughness={0.2} metalness={0.8} />
      </mesh>
      {/* Twin Glowing Energy Channels */}
      <mesh position={[-0.4, 0, 0.31]}>
        <boxGeometry args={[0.08, 1.6, 0.02]} />
        <meshBasicMaterial color="#00d1ff" />
      </mesh>
      <mesh position={[0.4, 0, 0.31]}>
        <boxGeometry args={[0.08, 1.6, 0.02]} />
        <meshBasicMaterial color="#00ffb2" />
      </mesh>
      {/* Display Portal */}
      <mesh position={[0, 0.6, 0.31]}>
        <boxGeometry args={[0.7, 0.5, 0.02]} />
        <meshPhysicalMaterial color="#7b61ff" transmission={0.8} transparent opacity={0.8} />
      </mesh>
    </group>
  );
}

function ModelStorage() {
  const meshRef = useRef<Group>(null);
  useFrame((state) => {
    const t = state.clock.getElapsedTime();
    if (meshRef.current) {
      meshRef.current.rotation.y = t * 0.15;
    }
  });

  return (
    <group ref={meshRef}>
      {/* High Density Tesla-style Battery Bank */}
      <mesh>
        <boxGeometry args={[1.6, 2.0, 1.0]} />
        <meshPhysicalMaterial color="#0b1120" roughness={0.3} metalness={0.9} />
      </mesh>
      {/* Procedural battery cell indicator rows */}
      {[-0.6, -0.2, 0.2, 0.6].map((y, idx) => (
        <mesh key={idx} position={[0, y, 0.51]}>
          <boxGeometry args={[1.2, 0.15, 0.02]} />
          <meshBasicMaterial color={idx % 2 === 0 ? "#00ffb2" : "#7b61ff"} transparent opacity={0.8} />
        </mesh>
      ))}
    </group>
  );
}

function ModelGrid() {
  const meshRef = useRef<Group>(null);
  useFrame((state) => {
    const t = state.clock.getElapsedTime();
    if (meshRef.current) {
      meshRef.current.rotation.y = t * 0.1;
      meshRef.current.rotation.x = Math.sin(t * 0.3) * 0.08;
    }
  });

  return (
    <group ref={meshRef}>
      {/* Holographic energy grids transformer substructure */}
      <mesh>
        <boxGeometry args={[1.8, 1.6, 1.8]} />
        <meshBasicMaterial color="#00d1ff" wireframe transparent opacity={0.3} />
      </mesh>
      {/* Floating inner core transformer coil */}
      <mesh position={[0, 0, 0]}>
        <cylinderGeometry args={[0.4, 0.4, 1.0, 16]} />
        <meshBasicMaterial color="#7b61ff" wireframe transparent opacity={0.6} />
      </mesh>
      {/* Top energy distributor rings */}
      <mesh position={[0, 0.8, 0]} rotation={[Math.PI / 2, 0, 0]}>
        <torusGeometry args={[0.7, 0.04, 6, 24]} />
        <meshBasicMaterial color="#00ffb2" transparent opacity={0.8} />
      </mesh>
    </group>
  );
}

export default function ChargerShowcase() {
  const [activeTab, setActiveTab] = useState(0);

  const options = [
    {
      name: "AC smart charger",
      power: "22 kW",
      useCase: "Home & Destination Charging",
      features: ["OCPP 2.0.1 Enabled", "Smart Billing", "Dual Connectors", "RFID Authentication"],
      color: "#00d1ff",
      model: <ModelAC />,
    },
    {
      name: "DC hyper charger",
      power: "450 kW",
      useCase: "Highway Fleet Fast Charge",
      features: ["Liquid Cooled Cables", "AI Load Balancing", "Volumetric Telemetry", "Dual CCS2 Gun Configurations"],
      color: "#00ffb2",
      model: <ModelDC />,
    },
    {
      name: "Megawatt Storage",
      power: "1.2 MWh",
      useCase: "Peak Load Grid Support",
      features: ["Lithium Iron Phosphate cells", "Predictive Charging Integration", "Dynamic Pricing Tuned", "Auto-Island Functionality"],
      color: "#7b61ff",
      model: <ModelStorage />,
    },
    {
      name: "Hyperion Micro-Grid",
      power: "Virtual Grid",
      useCase: "AI Energy Control Hub",
      features: ["Realtime Load Redistribution", "Smart Grid Telemetry", "100% Carbon-Neutral Energy Allocations", "Instant Grid Stabilization"],
      color: "#00ffb2",
      model: <ModelGrid />,
    },
  ];

  return (
    <section id="showcase" className="relative py-24 bg-[#050816] overflow-hidden">
      {/* Holographic Grid overlays */}
      <div className="absolute inset-0 cyber-grid-dense opacity-20 pointer-events-none" />
      
      <div className="max-w-7xl mx-auto px-6 relative z-10">
        
        {/* Title row */}
        <div className="text-center max-w-3xl mx-auto mb-16">
          <span className="text-xs font-bold uppercase tracking-widest text-[#7b61ff] font-orbitron">HARDWARE ECOSYSTEM</span>
          <h2 className="text-3xl md:text-5xl font-black uppercase font-orbitron mt-3 tracking-tight">Futuristic Hardware Suite</h2>
          <p className="text-gray-400 mt-4 text-sm md:text-base">
            Procedural 3D renders of the charging cabinets, energy storage units, and AI power grid interfaces deployed globally.
          </p>
        </div>

        {/* Showcase Arena Layout */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          
          {/* Left Column: Interactive models selection buttons & descriptors */}
          <div className="lg:col-span-5 flex flex-col space-y-6">
            
            {/* Tabs selector */}
            <div className="grid grid-cols-2 gap-3">
              {options.map((opt, idx) => (
                <button
                  key={idx}
                  onClick={() => setActiveTab(idx)}
                  className={`px-4 py-3.5 rounded-xl border text-xs font-extrabold uppercase tracking-wider font-orbitron transition-all duration-300 ${
                    activeTab === idx
                      ? "border-[#00ffb2] text-[#00ffb2] bg-[#00ffb2]/5 shadow-[0_0_15px_rgba(0,255,178,0.1)]"
                      : "border-white/10 text-gray-400 bg-[#0b1120] hover:border-white/30 hover:text-white"
                  }`}
                >
                  {opt.name}
                </button>
              ))}
            </div>

            {/* Spec details card of selected hardware */}
            <div className="glass-card p-8 rounded-2xl border border-white/5 relative min-h-[300px] flex flex-col justify-between">
              <AnimatePresence mode="wait">
                <motion.div
                  key={activeTab}
                  initial={{ opacity: 0, y: 15 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -15 }}
                  transition={{ duration: 0.3 }}
                >
                  <div>
                    <span className="text-[10px] font-mono border border-white/10 px-2.5 py-1 rounded bg-white/5 uppercase tracking-widest text-[#00ffb2]">
                      {options[activeTab].useCase}
                    </span>
                    <h3 className="text-2xl font-black font-orbitron uppercase text-white mt-4">
                      {options[activeTab].name}
                    </h3>
                    <div className="flex items-center space-x-2 mt-2">
                      <Zap className="w-4 h-4 text-cyan-400 animate-pulse" />
                      <span className="text-sm font-mono text-cyan-400 font-bold">CAPACITY: {options[activeTab].power}</span>
                    </div>
                  </div>

                  {/* Feature Bullets floating labels */}
                  <div className="mt-6 space-y-3">
                    {options[activeTab].features.map((feat, fIdx) => (
                      <div key={fIdx} className="flex items-center space-x-3 text-xs text-gray-300 font-medium">
                        <ShieldCheck className="w-4 h-4 text-[#00ffb2] shrink-0" />
                        <span className="tracking-wide">{feat}</span>
                      </div>
                    ))}
                  </div>
                </motion.div>
              </AnimatePresence>
            </div>

          </div>

          {/* Right Column: High-fidelity 3D Canvas rendering rotating procedural hardware */}
          <div className="lg:col-span-7 h-[400px] md:h-[500px] glass-card rounded-3xl border border-white/5 relative overflow-hidden bg-gradient-to-b from-[#050816] via-transparent to-[#050816]">
            {/* Interactive instructions label */}
            <div className="absolute top-4 left-4 z-20 flex items-center space-x-2 px-3 py-1 bg-white/5 rounded-full border border-white/10 text-[9px] font-mono tracking-widest text-gray-400 uppercase">
              <Info className="w-3 h-3 text-[#00d1ff]" />
              <span>Drag to rotate // Scroll to zoom</span>
            </div>

            {/* Glowing bottom platform base plate */}
            <div className="absolute bottom-10 left-1/2 transform -translate-x-1/2 z-10 w-44 h-1.5 rounded-full bg-gradient-to-r from-transparent via-[#00ffb2] to-transparent opacity-60 blur-[1px]" />
            
            <Canvas camera={{ position: [0, 0.2, 4.0], fov: 45 }}>
              <ambientLight intensity={0.6} />
              <directionalLight position={[5, 5, 5]} intensity={1.5} color="#00ffb2" />
              <pointLight position={[-5, 3, -3]} intensity={1.0} color="#7b61ff" />
              
              <Float speed={1.5} rotationIntensity={0.2} floatIntensity={0.5}>
                <group position={[0, -0.4, 0]}>
                  {options[activeTab].model}
                </group>
              </Float>
              
              <OrbitControls enableZoom={true} enablePan={false} maxDistance={6.0} minDistance={2.5} />
            </Canvas>
          </div>

        </div>

      </div>
    </section>
  );
}
