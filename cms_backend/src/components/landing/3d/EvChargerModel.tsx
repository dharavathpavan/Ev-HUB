"use client";

import React, { useRef, useState } from "react";
import { useFrame } from "@react-three/fiber";
import { Mesh, TorusGeometry, Group } from "three";
import { Float } from "@react-three/drei";

export default function EvChargerModel() {
  const groupRef = useRef<Group>(null);
  const coreRef = useRef<Mesh>(null);
  const ring1Ref = useRef<Mesh>(null);
  const ring2Ref = useRef<Mesh>(null);
  const [hovered, setHovered] = useState(false);

  useFrame((state) => {
    const t = state.clock.getElapsedTime();
    
    // Rotating main base
    if (groupRef.current) {
      groupRef.current.rotation.y = t * (hovered ? 0.8 : 0.2);
    }
    
    // Core pulsing glow
    if (coreRef.current) {
      coreRef.current.rotation.y = -t * 1.5;
      coreRef.current.rotation.x = t * 0.5;
      const pulse = 1 + Math.sin(t * 5) * 0.08;
      coreRef.current.scale.set(pulse, pulse, pulse);
    }

    // Outer ring rotations
    if (ring1Ref.current) {
      ring1Ref.current.rotation.x = t * 0.8;
      ring1Ref.current.rotation.y = t * 0.4;
    }

    if (ring2Ref.current) {
      ring2Ref.current.rotation.y = -t * 0.6;
      ring2Ref.current.rotation.z = t * 0.9;
    }
  });

  return (
    <Float speed={2} rotationIntensity={0.5} floatIntensity={1}>
      <group 
        ref={groupRef}
        onPointerOver={() => setHovered(true)}
        onPointerOut={() => setHovered(false)}
      >
        {/* Sleek Outer Cabinet Frame (Procedural Industrial Shell) */}
        <mesh position={[0, -0.2, 0]}>
          <boxGeometry args={[1.2, 3.2, 0.4]} />
          <meshPhysicalMaterial 
            color="#0b1120"
            roughness={0.1}
            metalness={0.9}
            clearcoat={1.0}
            clearcoatRoughness={0.1}
          />
        </mesh>

        {/* Center Glass Display Console Pane */}
        <mesh position={[0, 0.4, 0.21]}>
          <boxGeometry args={[0.9, 1.4, 0.02]} />
          <meshPhysicalMaterial 
            color="#00d1ff"
            transmission={0.9}
            opacity={1}
            transparent
            roughness={0}
            ior={1.5}
            thickness={0.1}
          />
        </mesh>

        {/* Dynamic Holographic Energy Sphere Core (Pulsing Center) */}
        <mesh ref={coreRef} position={[0, 0.4, 0]}>
          <sphereGeometry args={[0.35, 32, 32]} />
          <meshBasicMaterial 
            color={hovered ? "#00ffb2" : "#00d1ff"}
            wireframe
            transparent
            opacity={0.8}
          />
        </mesh>
        
        {/* Core Solid Glow Sphere */}
        <mesh position={[0, 0.4, 0]}>
          <sphereGeometry args={[0.2, 16, 16]} />
          <meshBasicMaterial 
            color={hovered ? "#00ffb2" : "#7b61ff"}
            transparent
            opacity={0.6}
          />
        </mesh>

        {/* Orbiting Ring 1 (Electric Blue Grid Torus) */}
        <mesh ref={ring1Ref} position={[0, 0.4, 0]}>
          <torusGeometry args={[0.65, 0.03, 8, 48]} />
          <meshBasicMaterial 
            color="#00d1ff"
            wireframe
            transparent
            opacity={0.7}
          />
        </mesh>

        {/* Orbiting Ring 2 (Purple Glowing Torus) */}
        <mesh ref={ring2Ref} position={[0, 0.4, 0]}>
          <torusGeometry args={[0.8, 0.02, 6, 36]} />
          <meshBasicMaterial 
            color="#7b61ff"
            transparent
            opacity={0.5}
          />
        </mesh>

        {/* Holographic HUD Ring Base Indicators */}
        <mesh position={[0, -1.85, 0]} rotation={[-Math.PI / 2, 0, 0]}>
          <ringGeometry args={[0.9, 1.2, 64]} />
          <meshBasicMaterial 
            color="#00ffb2" 
            side={2} 
            transparent 
            opacity={0.4} 
            wireframe 
          />
        </mesh>

        {/* Vertical Volumetric Neon Light Tubes */}
        <mesh position={[-0.58, -0.2, 0.2]}>
          <cylinderGeometry args={[0.02, 0.02, 3, 8]} />
          <meshBasicMaterial color="#00ffb2" transparent opacity={0.7} />
        </mesh>

        <mesh position={[0.58, -0.2, 0.2]}>
          <cylinderGeometry args={[0.02, 0.02, 3, 8]} />
          <meshBasicMaterial color="#00d1ff" transparent opacity={0.7} />
        </mesh>

        {/* Dynamic Energy Point Particles Grid inside the core */}
        <points position={[0, 0.4, 0]}>
          <sphereGeometry args={[0.5, 10, 10]} />
          <pointsMaterial 
            color="#00ffb2" 
            size={0.03} 
            sizeAttenuation
            transparent
            opacity={0.9}
          />
        </points>
      </group>
    </Float>
  );
}
