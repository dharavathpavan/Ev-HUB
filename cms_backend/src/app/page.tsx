"use client";

import React, { useEffect, useState } from "react";
import Lenis from "lenis";
import { motion, useScroll, useSpring } from "framer-motion";

// Section Imports
import Navbar from "@/components/landing/Navbar";
import Hero from "@/components/landing/Hero";
import Network from "@/components/landing/Network";
import ChargingFlow from "@/components/landing/ChargingFlow";
import ChargerShowcase from "@/components/landing/ChargerShowcase";
import DashboardSection from "@/components/landing/DashboardSection";
import MobileApp from "@/components/landing/MobileApp";
import VendorFleet from "@/components/landing/VendorFleet";
import EnergyIntelligence from "@/components/landing/EnergyIntelligence";
import DeveloperApi from "@/components/landing/DeveloperApi";
import FinalCTA from "@/components/landing/FinalCTA";
import Footer from "@/components/landing/Footer";

export default function Home() {
  const [mounted, setMounted] = useState(false);
  const [mousePos, setMousePos] = useState({ x: 0, y: 0 });

  // Scroll Progress calculations for the cinematic neon progress bar
  const { scrollYProgress } = useScroll();
  const scaleX = useSpring(scrollYProgress, {
    stiffness: 100,
    damping: 30,
    restDelta: 0.001,
  });

  useEffect(() => {
    setMounted(true);

    // Initialize Lenis Smooth Scroll
    const lenis = new Lenis({
      duration: 1.2,
      easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
      wheelMultiplier: 1.1,
      touchMultiplier: 1.5,
    });

    function raf(time: number) {
      lenis.raf(time);
      requestAnimationFrame(raf);
    }

    requestAnimationFrame(raf);

    // Track mouse coordinates for cursor ambient lighting glow
    const handleMouseMove = (e: MouseEvent) => {
      setMousePos({ x: e.clientX, y: e.clientY });
    };
    window.addEventListener("mousemove", handleMouseMove);

    return () => {
      lenis.destroy();
      window.removeEventListener("mousemove", handleMouseMove);
    };
  }, []);

  if (!mounted) {
    return (
      <div className="fixed inset-0 bg-[#050816] flex items-center justify-center z-50">
        <div className="flex flex-col items-center space-y-4">
          <div className="w-12 h-12 border-2 border-cyan-500 border-t-transparent rounded-full animate-spin" />
          <span className="text-[#00d1ff] font-bold tracking-widest font-orbitron animate-pulse">
            LOADING ECOSYSTEM...
          </span>
        </div>
      </div>
    );
  }

  return (
    <main className="relative min-h-screen bg-[#050816] text-white selection:bg-[#00ffb2] selection:text-black">
      {/* Cinematic Top Neon Scroll Progress bar */}
      <motion.div id="scroll-progress" style={{ scaleX }} />

      {/* Cybernetic Ambient Mouse Lighting glow */}
      <div
        className="pointer-events-none fixed -inset-px z-30 rounded-full transition-all duration-300 opacity-20 hidden md:block"
        style={{
          background: `radial-gradient(400px circle at ${mousePos.x}px ${mousePos.y}px, rgba(0, 209, 255, 0.15), transparent 80%)`,
        }}
      />

      {/* 1️⃣ NAVBAR */}
      <Navbar />

      {/* 2️⃣ HERO SECTION (FULLSCREEN 3D EXPERIENCE) */}
      <div id="hero">
        <Hero />
      </div>

      {/* 3️⃣ LIVE NETWORK SECTION */}
      <div id="network">
        <Network />
      </div>

      {/* 4️⃣ INTERACTIVE CHARGING FLOW */}
      <div id="features">
        <ChargingFlow />
      </div>

      {/* 5️⃣ 3D CHARGER SHOWCASE */}
      <div id="technology">
        <ChargerShowcase />
      </div>

      {/* 6️⃣ REALTIME DASHBOARD SECTION */}
      <DashboardSection />

      {/* 7️⃣ MOBILE APP SHOWCASE */}
      <div id="mobile">
        <MobileApp />
      </div>

      {/* 8️⃣ VENDOR & FLEET SECTION */}
      <div id="vendors">
        <VendorFleet />
      </div>

      {/* 9️⃣ AI ENERGY INTELLIGENCE SECTION */}
      <EnergyIntelligence />

      {/* 🔟 DEVELOPER API SECTION */}
      <div id="developers">
        <DeveloperApi />
      </div>

      {/* 1️⃣1️⃣ FINAL CTA SECTION */}
      <FinalCTA />

      {/* 1️⃣2️⃣ FOOTER */}
      <Footer />
    </main>
  );
}
