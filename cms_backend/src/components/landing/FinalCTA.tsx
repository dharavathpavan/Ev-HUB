"use client";

import React from "react";
import { motion } from "framer-motion";
import { ArrowUpRight, Shield, Rocket, Download } from "lucide-react";

export default function FinalCTA() {
  return (
    <section className="relative min-h-[80vh] flex items-center justify-center overflow-hidden py-24 bg-[#050816] border-t border-cyan-500/10">
      {/* Cyber grid overlays */}
      <div className="absolute inset-0 cyber-grid opacity-30 pointer-events-none" />
      <div className="absolute inset-0 cyber-grid-dense opacity-20 pointer-events-none" />

      {/* Massive Futuristic Sunrise Light Source in the background */}
      <div className="absolute bottom-0 left-1/2 -translate-x-1/2 w-[140%] md:w-[100%] aspect-[2/1] rounded-t-full bg-gradient-to-t from-[#7b61ff]/20 via-[#00d1ff]/10 to-transparent blur-[120px] pointer-events-none translate-y-1/3" />
      <div className="absolute bottom-0 left-1/2 -translate-x-1/2 w-[80%] md:w-[60%] aspect-[2/1] rounded-t-full bg-gradient-to-t from-[#00ffb2]/15 via-transparent to-transparent blur-[60px] pointer-events-none translate-y-1/2" />
      <div className="absolute bottom-0 left-0 right-0 h-[2px] bg-gradient-to-r from-transparent via-[#00d1ff]/50 to-transparent opacity-80" />

      {/* Core Glowing Sunrise Core */}
      <div className="absolute bottom-0 left-1/2 -translate-x-1/2 w-[300px] h-[80px] bg-[#00d1ff]/30 rounded-t-full blur-[30px] translate-y-1/2 pointer-events-none" />

      {/* Floating Particle Orbs */}
      <div className="absolute top-[20%] left-[15%] w-72 h-72 rounded-full bg-[#00d1ff]/5 blur-[60px] animate-pulse-slow pointer-events-none" />
      <div className="absolute bottom-[30%] right-[10%] w-96 h-96 rounded-full bg-[#7b61ff]/5 blur-[80px] animate-pulse-slow pointer-events-none" />

      <div className="relative max-w-5xl mx-auto px-6 text-center z-10">
        {/* Tech Badge */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="inline-flex items-center space-x-2 px-4 py-1.5 rounded-full glass-card border border-cyan-500/30 text-xs font-semibold uppercase tracking-widest text-[#00d1ff] mb-8 font-orbitron text-glow-blue"
        >
          <span className="w-2 h-2 rounded-full bg-[#00ffb2] animate-ping" />
          <span>Ecosystem Horizon 2026</span>
        </motion.div>

        {/* Headline */}
        <motion.h2
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8, delay: 0.1 }}
          className="text-4xl md:text-7xl font-extrabold tracking-tight text-white mb-6 font-orbitron leading-tight"
        >
          Build The Future Of <br />
          <span className="bg-gradient-to-r from-[#00d1ff] via-[#00ffb2] to-[#7b61ff] bg-clip-text text-transparent text-glow-blue">
            Smart Mobility
          </span>
        </motion.h2>

        {/* Subtitle */}
        <motion.p
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8, delay: 0.2 }}
          className="text-base md:text-xl text-gray-400 max-w-2xl mx-auto mb-12 leading-relaxed"
        >
          Integrate, manage, and scale ultra-fast charging infrastructures with the world&apos;s most intelligent, OCPP-compliant clean energy platform.
        </motion.p>

        {/* Buttons */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8, delay: 0.3 }}
          className="flex flex-col sm:flex-row items-center justify-center gap-6"
        >
          {/* Main platform button */}
          <a
            href="http://localhost:8080/#/dashboard"
            target="_blank"
            rel="noopener noreferrer"
            className="group flex items-center justify-center space-x-2 w-full sm:w-auto px-8 py-4 rounded-full bg-gradient-to-r from-[#00d1ff] to-[#00ffb2] text-black font-extrabold uppercase tracking-widest text-xs font-orbitron hover:scale-105 hover:shadow-[0_0_35px_rgba(0,209,255,0.5)] transition-all duration-300 cursor-pointer"
          >
            <Rocket className="w-4 h-4 text-black group-hover:translate-x-0.5 group-hover:-translate-y-0.5 transition-transform duration-200" />
            <span>Launch Platform</span>
            <ArrowUpRight className="w-4 h-4 text-black" />
          </a>

          {/* Become Partner / Vendor button */}
          <a
            href="#vendors"
            className="btn-neon-green flex items-center justify-center space-x-2 w-full sm:w-auto px-8 py-4 rounded-full text-xs font-bold uppercase tracking-widest text-white font-orbitron cursor-pointer"
          >
            <Shield className="w-4 h-4 text-[#00ffb2]" />
            <span>Partner With Us</span>
          </a>

          {/* Mobile Download Button */}
          <a
            href="#mobile"
            className="btn-neon-blue flex items-center justify-center space-x-2 w-full sm:w-auto px-8 py-4 rounded-full text-xs font-bold uppercase tracking-widest text-white font-orbitron cursor-pointer"
          >
            <Download className="w-4 h-4 text-[#00d1ff]" />
            <span>Download App</span>
          </a>
        </motion.div>

        {/* Small Trust Indicators */}
        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          transition={{ duration: 1, delay: 0.5 }}
          className="mt-16 grid grid-cols-2 md:grid-cols-3 gap-6 max-w-3xl mx-auto pt-8 border-t border-cyan-500/10 text-xs tracking-wider text-gray-500 uppercase font-orbitron"
        >
          <div>
            <span className="text-[#00ffb2] font-semibold block text-base mb-1">OCPP 2.0.1</span> Fully Compliant
          </div>
          <div className="border-l border-cyan-500/10 hidden md:block">
            <span className="text-[#00d1ff] font-semibold block text-base mb-1">PCI-DSS LEVEL 1</span> Secure Payments
          </div>
          <div className="border-l border-cyan-500/10">
            <span className="text-[#7b61ff] font-semibold block text-base mb-1">SLA 99.99%</span> Enterprise Uptime
          </div>
        </motion.div>
      </div>
    </section>
  );
}
