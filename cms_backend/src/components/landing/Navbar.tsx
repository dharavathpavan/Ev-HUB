"use client";

import React, { useState, useEffect } from "react";
import { Bolt } from "lucide-react";
import { motion } from "framer-motion";

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      if (window.scrollY > 50) {
        setScrolled(true);
      } else {
        setScrolled(false);
      }
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  return (
    <motion.nav 
      initial={{ y: -100, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
      className={`fixed top-0 left-0 w-full z-50 transition-all duration-300 ${
        scrolled 
          ? "glass-navbar py-4 shadow-[0_4px_30px_rgba(0,0,0,0.4)]" 
          : "bg-transparent py-6"
      }`}
    >
      <div className="max-w-7xl mx-auto px-6 flex items-center justify-between">
        {/* Left: EV Logo */}
        <a href="#" className="flex items-center space-x-2 group">
          <div className="p-2 bg-cyan-500/10 rounded-lg border border-cyan-500/20 group-hover:border-cyan-500/50 transition-all duration-300">
            <Bolt className="w-6 h-6 text-[#00d1ff] group-hover:scale-110 transition-transform duration-300" />
          </div>
          <span className="text-xl font-bold tracking-widest text-white font-orbitron group-hover:text-[#00ffb2] transition-colors duration-300">
            HYPERION
          </span>
        </a>

        {/* Center: Main Links */}
        <div className="hidden md:flex items-center space-x-8">
          {[
            { label: "Features", href: "#features" },
            { label: "Network", href: "#network" },
            { label: "Technology", href: "#technology" },
            { label: "Vendors", href: "#vendors" },
            { label: "Developers", href: "#developers" },
          ].map((link, idx) => (
            <a 
              key={idx}
              href={link.href}
              className="text-sm font-semibold tracking-wider text-gray-300 hover:text-[#00ffb2] hover:text-glow-green transition-all duration-300 relative group py-2"
            >
              {link.label}
              <span className="absolute bottom-0 left-0 w-0 h-[1.5px] bg-[#00ffb2] transition-all duration-300 group-hover:w-full" />
            </a>
          ))}
        </div>

        {/* Right: Quick actions */}
        <div className="flex items-center space-x-4">
          <button className="hidden sm:block text-sm font-semibold tracking-wider text-white hover:text-[#00d1ff] transition-all duration-300">
            Login
          </button>
          
          <a 
            href="http://localhost:8080/#/dashboard" 
            target="_blank"
            rel="noopener noreferrer"
            className="btn-neon-blue px-6 py-2.5 rounded-full text-xs font-bold tracking-wider text-white uppercase font-orbitron text-glow-blue"
          >
            Launch Platform
          </a>
        </div>
      </div>
    </motion.nav>
  );
}
