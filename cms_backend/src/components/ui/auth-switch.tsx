"use client";

import { cn } from "@/lib/utils";
import { useState } from "react";
import { Mail, Lock, User, ArrowRight, ShieldCheck, Zap } from "lucide-react";
import Image from "next/image";

export default function AuthSwitch() {
  const [isLogin, setIsLogin] = useState(true);
  const [count, setCount] = useState(0); // Kept the counter from the example as requested

  return (
    <div className="min-h-screen w-full flex items-center justify-center bg-zinc-50 p-4">
      <div className="w-full max-w-5xl bg-white rounded-3xl shadow-2xl overflow-hidden flex flex-col md:flex-row min-h-[600px]">
        
        {/* Left Side: Form */}
        <div className="w-full md:w-1/2 p-8 md:p-12 flex flex-col justify-center relative">
          <div className="absolute top-8 left-8 flex items-center gap-2">
            <Zap className="w-6 h-6 text-blue-600" />
            <span className="font-bold text-xl tracking-tight text-zinc-900">Bleuto</span>
          </div>

          <div className="max-w-sm w-full mx-auto mt-12">
            <h2 className="text-3xl font-bold text-zinc-900 mb-2">
              {isLogin ? "Welcome back" : "Create an account"}
            </h2>
            <p className="text-zinc-500 mb-8">
              {isLogin 
                ? "Enter your details to access your dashboard." 
                : "Sign up today to start managing your EV charging stations."}
            </p>

            <form className="space-y-4" onSubmit={(e) => e.preventDefault()}>
              {!isLogin && (
                <div className="space-y-2">
                  <label className="text-sm font-medium text-zinc-700">Full Name</label>
                  <div className="relative">
                    <User className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-zinc-400" />
                    <input 
                      type="text" 
                      placeholder="John Doe" 
                      className="w-full pl-10 pr-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl focus:ring-2 focus:ring-blue-600 focus:border-transparent outline-none transition-all"
                    />
                  </div>
                </div>
              )}

              <div className="space-y-2">
                <label className="text-sm font-medium text-zinc-700">Email Address</label>
                <div className="relative">
                  <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-zinc-400" />
                  <input 
                    type="email" 
                    placeholder="you@example.com" 
                    className="w-full pl-10 pr-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl focus:ring-2 focus:ring-blue-600 focus:border-transparent outline-none transition-all"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <div className="flex justify-between items-center">
                  <label className="text-sm font-medium text-zinc-700">Password</label>
                  {isLogin && <a href="#" className="text-sm text-blue-600 font-medium hover:underline">Forgot password?</a>}
                </div>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-zinc-400" />
                  <input 
                    type="password" 
                    placeholder="••••••••" 
                    className="w-full pl-10 pr-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl focus:ring-2 focus:ring-blue-600 focus:border-transparent outline-none transition-all"
                  />
                </div>
              </div>

              <button className="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 rounded-xl flex items-center justify-center gap-2 transition-all mt-6 shadow-lg shadow-blue-200">
                {isLogin ? "Sign In" : "Create Account"}
                <ArrowRight className="w-4 h-4" />
              </button>

              <div className="relative my-8">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t border-zinc-200"></div>
                </div>
                <div className="relative flex justify-center text-sm">
                  <span className="px-2 bg-white text-zinc-500">Or continue with</span>
                </div>
              </div>

              <button type="button" className="w-full bg-white border border-zinc-200 hover:bg-zinc-50 text-zinc-700 font-medium py-3 rounded-xl flex items-center justify-center gap-2 transition-all">
                <svg className="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
                  <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
                  <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z" fill="#FBBC05"/>
                  <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z" fill="#EA4335"/>
                </svg>
                Google
              </button>
            </form>

            <p className="text-center text-sm text-zinc-600 mt-8">
              {isLogin ? "Don't have an account?" : "Already have an account?"}{" "}
              <button 
                onClick={() => setIsLogin(!isLogin)} 
                className="text-blue-600 font-bold hover:underline"
              >
                {isLogin ? "Sign up" : "Log in"}
              </button>
            </p>

            {/* Legacy component example counter requested in prompt */}
            <div className={cn("flex flex-col items-center gap-4 p-4 rounded-lg mt-8 bg-zinc-50 border border-zinc-100 hidden")}>
              <h1 className="text-lg font-bold mb-2">Component Example</h1>
              <h2 className="text-xl font-semibold">{count}</h2>
              <div className="flex gap-2">
                <button className="w-8 h-8 rounded bg-zinc-200" onClick={() => setCount((prev) => prev - 1)}>-</button>
                <button className="w-8 h-8 rounded bg-zinc-200" onClick={() => setCount((prev) => prev + 1)}>+</button>
              </div>
            </div>

          </div>
        </div>

        {/* Right Side: Image/Banner */}
        <div className="w-full md:w-1/2 relative bg-zinc-900 hidden md:block">
          <Image 
            src="https://images.unsplash.com/photo-1563720223185-11003d516935?auto=format&fit=crop&w=1200&q=80" 
            alt="EV Charging Station" 
            fill
            priority
            className="object-cover opacity-60"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-zinc-900/90 via-zinc-900/20 to-transparent flex flex-col justify-end p-12">
            <div className="inline-flex items-center gap-2 bg-blue-600/20 backdrop-blur-md border border-blue-500/30 text-blue-300 px-4 py-2 rounded-full mb-6 w-fit">
              <ShieldCheck className="w-4 h-4" />
              <span className="text-sm font-medium">Enterprise Grade Security</span>
            </div>
            <h3 className="text-3xl font-bold text-white mb-4 leading-tight">
              Manage your EV infrastructure with intelligence.
            </h3>
            <p className="text-zinc-300 text-lg">
              Join thousands of hub operators optimizing their revenue and load balancing through Bleuto.
            </p>
          </div>
        </div>

      </div>
    </div>
  );
}
