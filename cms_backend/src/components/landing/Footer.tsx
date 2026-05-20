"use client";

import React, { useState } from "react";
import { Bolt, ArrowRight, Globe, ShieldCheck, Leaf } from "lucide-react";
import { motion } from "framer-motion";

export default function Footer() {
  const [email, setEmail] = useState("");
  const [subscribed, setSubscribed] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (email) {
      setSubscribed(true);
      setEmail("");
    }
  };

  return (
    <footer className="relative bg-[#050816] text-gray-400 overflow-hidden pt-20 pb-12 border-t border-cyan-500/10 font-jakarta">
      {/* Background visual accents */}
      <div className="absolute bottom-0 right-0 w-[400px] h-[400px] bg-[#7b61ff]/5 rounded-full blur-[100px] pointer-events-none" />
      <div className="absolute top-0 left-0 w-[400px] h-[400px] bg-[#00d1ff]/5 rounded-full blur-[100px] pointer-events-none" />

      <div className="max-w-7xl mx-auto px-6 relative z-10">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-12 pb-16 border-b border-cyan-500/10">
          
          {/* Logo & Vision Block */}
          <div className="lg:col-span-2 space-y-6">
            <a href="#" className="flex items-center space-x-2 group w-fit">
              <div className="p-2 bg-cyan-500/10 rounded-lg border border-cyan-500/20 group-hover:border-[#00ffb2]/50 transition-all duration-300">
                <Bolt className="w-6 h-6 text-[#00d1ff] group-hover:scale-110 transition-transform duration-300" />
              </div>
              <span className="text-xl font-bold tracking-widest text-white font-orbitron group-hover:text-[#00ffb2] transition-colors duration-300">
                HYPERION
              </span>
            </a>
            
            <p className="text-sm text-gray-400 max-w-sm leading-relaxed">
              Global smart grid integration systems and ultra-fast charging platforms engineered for next-generation electric mobility corridors.
            </p>

            {/* Newsletter Subscription */}
            <form onSubmit={handleSubmit} className="space-y-3">
              <label className="block text-xs font-semibold uppercase tracking-wider text-gray-500 font-orbitron">
                Receive Technical Updates
              </label>
              <div className="flex max-w-md">
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="name@company.com"
                  required
                  className="flex-grow bg-slate-900/60 border border-cyan-500/25 rounded-l-lg px-4 py-3 text-sm text-white placeholder-gray-500 focus:outline-none focus:border-[#00ffb2] focus:ring-1 focus:ring-[#00ffb2]/30 transition-all duration-300"
                />
                <button
                  type="submit"
                  className="bg-cyan-500 hover:bg-[#00ffb2] text-black font-semibold rounded-r-lg px-5 py-3 transition-all duration-300 flex items-center justify-center cursor-pointer"
                >
                  {subscribed ? (
                    <span className="text-xs font-bold font-orbitron">SENT</span>
                  ) : (
                    <ArrowRight className="w-4 h-4 text-black" />
                  )}
                </button>
              </div>
              {subscribed && (
                <p className="text-xs text-[#00ffb2] font-semibold">
                  Thank you! You have been subscribed to Hyperion dispatch.
                </p>
              )}
            </form>
          </div>

          {/* Column 1: Ecosystem Network */}
          <div className="space-y-4">
            <h4 className="text-sm font-semibold uppercase tracking-widest text-white font-orbitron text-glow-blue">
              Ecosystem
            </h4>
            <ul className="space-y-2.5 text-sm">
              <li>
                <a href="#features" className="hover:text-[#00ffb2] transition-colors duration-200">
                  Smart Hardware
                </a>
              </li>
              <li>
                <a href="#network" className="hover:text-[#00ffb2] transition-colors duration-200">
                  Global Map
                </a>
              </li>
              <li>
                <a href="#technology" className="hover:text-[#00ffb2] transition-colors duration-200">
                  Energy AI
                </a>
              </li>
              <li>
                <a href="#vendors" className="hover:text-[#00ffb2] transition-colors duration-200">
                  Vendor Portal
                </a>
              </li>
              <li>
                <a href="http://localhost:8080/#/dashboard" target="_blank" rel="noopener noreferrer" className="hover:text-[#00ffb2] transition-colors duration-200">
                  Control Console
                </a>
              </li>
            </ul>
          </div>

          {/* Column 2: Developers */}
          <div className="space-y-4">
            <h4 className="text-sm font-semibold uppercase tracking-widest text-white font-orbitron text-glow-purple">
              Developers
            </h4>
            <ul className="space-y-2.5 text-sm">
              <li>
                <a href="#developers" className="hover:text-[#00ffb2] transition-colors duration-200">
                  API Documentation
                </a>
              </li>
              <li>
                <a href="#developers" className="hover:text-[#00ffb2] transition-colors duration-200">
                  OCPP Protocols
                </a>
              </li>
              <li>
                <a href="#developers" className="hover:text-[#00ffb2] transition-colors duration-200">
                  Websocket Hooks
                </a>
              </li>
              <li>
                <a href="https://github.com" target="_blank" rel="noopener noreferrer" className="hover:text-[#00ffb2] transition-colors duration-200 flex items-center space-x-1">
                  <span>GitHub Repos</span>
                </a>
              </li>
              <li>
                <a href="#developers" className="hover:text-[#00ffb2] transition-colors duration-200">
                  System Status
                </a>
              </li>
            </ul>
          </div>

          {/* Column 3: Corporate */}
          <div className="space-y-4">
            <h4 className="text-sm font-semibold uppercase tracking-widest text-white font-orbitron text-glow-green">
              Corporate
            </h4>
            <ul className="space-y-2.5 text-sm">
              <li>
                <a href="#" className="hover:text-[#00ffb2] transition-colors duration-200">
                  Careers <span className="text-[10px] bg-cyan-500/20 text-[#00d1ff] border border-cyan-500/30 px-1.5 py-0.5 rounded font-orbitron ml-1">WE ARE HIRING</span>
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-[#00ffb2] transition-colors duration-200">
                  Press Room
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-[#00ffb2] transition-colors duration-200">
                  Privacy Policy
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-[#00ffb2] transition-colors duration-200">
                  Terms of Service
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-[#00ffb2] transition-colors duration-200">
                  Support Center
                </a>
              </li>
            </ul>
          </div>

        </div>

        {/* Lower Row: Socials, Copyright, Trust Icons */}
        <div className="pt-12 flex flex-col md:flex-row items-center justify-between gap-6">
          
          {/* Brand Info */}
          <div className="flex flex-col md:flex-row items-center gap-4 text-xs">
            <span>© {new Date().getFullYear()} Hyperion Energy Technologies Inc.</span>
            <div className="hidden md:block w-1.5 h-1.5 rounded-full bg-cyan-500/20" />
            <span className="flex items-center text-[#00ffb2]">
              <Leaf className="w-3.5 h-3.5 mr-1" />
              100% Carbon Neutral Fleet & Servers
            </span>
          </div>

          {/* Trust Badges */}
          <div className="flex items-center space-x-6 text-xs text-gray-500 uppercase font-orbitron">
            <span className="flex items-center">
              <ShieldCheck className="w-4 h-4 text-cyan-500 mr-1.5" />
              ISO 27001 SECURED
            </span>
            <span className="flex items-center">
              <Globe className="w-4 h-4 text-purple-500 mr-1.5" />
              MULTI-REGION REDUNDANCY
            </span>
          </div>

          {/* Social Links */}
          <div className="flex items-center space-x-4">
            {[
              {
                icon: (
                  <svg className="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M15 22v-4a4.8 4.8 0 0 0-1-3.5c3 0 6-2 6-5.5.08-1.25-.27-2.48-1-3.5.28-1.15.28-2.35 0-3.5 0 0-1 0-3 1.5-2.64-.5-5.36-.5-8 0C6 2 5 2 5 2c-.3 1.15-.3 2.35 0 3.5A5.403 5.403 0 0 0 4 9c0 3.5 3 5.5 6 5.5-.39.49-.68 1.05-.85 1.65-.17.6-.22 1.23-.15 1.85v4" />
                    <path d="M9 18c-4.51 2-5-2-7-2" />
                  </svg>
                ),
                href: "https://github.com"
              },
              {
                icon: (
                  <svg className="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M22 4s-.7 2.1-2 3.4c1.6 10-9.4 17.3-18 11.6 2.2.1 4.4-.6 6-2C3 15.5.5 9.6 3 5c2.2 2.6 5.6 4.1 9 4-.9-4.2 4-6.6 7-3.8 1.1 0 3-1.2 3-1.2z" />
                  </svg>
                ),
                href: "https://twitter.com"
              },
              {
                icon: (
                  <svg className="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M16 8a6 6 0 0 1 6 6v7h-4v-7a2 2 0 0 0-2-2 2 2 0 0 0-2 2v7h-4v-7a6 6 0 0 1 6-6z" />
                    <rect x="2" y="9" width="4" height="12" />
                    <circle cx="4" cy="4" r="2" />
                  </svg>
                ),
                href: "https://linkedin.com"
              }
            ].map((social, idx) => (
              <a
                key={idx}
                href={social.href}
                target="_blank"
                rel="noopener noreferrer"
                className="p-2.5 rounded-lg bg-slate-900/50 hover:bg-[#00ffb2]/10 border border-cyan-500/10 hover:border-[#00ffb2]/45 text-gray-400 hover:text-[#00ffb2] hover:shadow-[0_0_10px_rgba(0,255,178,0.2)] transition-all duration-300"
              >
                {social.icon}
              </a>
            ))}
          </div>

        </div>
      </div>
    </footer>
  );
}
