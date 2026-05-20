import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "⚡ EV HYPERION // Futuristic 3D EV Charging Ecosystem",
  description: "Experience the next generation of clean energy mobility. Real-time smart infrastructure, AI grid load balancing, and instant remote payments built for future smart cities.",
  keywords: ["EV Charging", "Smart Grid", "ThreeJS EV Landing", "Tesla energy style", "Cyberpunk Smart City", "OCPP Charger"],
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased selection:bg-cyan-500 selection:text-black">
        {children}
      </body>
    </html>
  );
}

