"use client";

import React, { useRef, useState } from "react";
import { useFrame } from "@react-three/fiber";
import { Group, Mesh } from "three";
import { Float } from "@react-three/drei";

export default function SmartphoneModel() {
  const phoneRef = useRef<Group>(null);
  const screenRef = useRef<Mesh>(null);
  const [hovered, setHovered] = useState(false);

  useFrame((state) => {
    const t = state.clock.getElapsedTime();
    if (phoneRef.current) {
      phoneRef.current.rotation.y = t * 0.4 + Math.sin(t * 0.2) * 0.2;
      phoneRef.current.rotation.x = Math.sin(t * 0.3) * 0.1;
    }
    if (screenRef.current) {
      // Screen shimmer effect
      screenRef.current.position.z = 0.05 + Math.sin(t * 2) * 0.002;
    }
  });

  return (
    <Float speed={3} rotationIntensity={0.6} floatIntensity={1.2}>
      <group 
        ref={phoneRef}
        onPointerOver={() => setHovered(true)}
        onPointerOut={() => setHovered(false)}
      >
        {/* Smartphone Outer Metallic Border/Chassis */}
        <mesh>
          <boxGeometry args={[1.5, 3.0, 0.08]} />
          <meshPhysicalMaterial 
            color="#0b1120"
            roughness={0.1}
            metalness={0.9}
            clearcoat={1.0}
          />
        </mesh>

        {/* Chassis Glowing Cyan Wireframe */}
        <mesh>
          <boxGeometry args={[1.52, 3.02, 0.09]} />
          <meshBasicMaterial 
            color={hovered ? "#00ffb2" : "#00d1ff"}
            wireframe
            transparent
            opacity={0.6}
          />
        </mesh>

        {/* Glass Front Touch Screen */}
        <mesh ref={screenRef} position={[0, 0, 0.05]}>
          <planeGeometry args={[1.4, 2.9]} />
          <meshPhysicalMaterial 
            color="#00d1ff"
            transmission={0.8}
            roughness={0.05}
            ior={1.6}
            thickness={0.05}
            transparent
            opacity={0.35}
          />
        </mesh>

        {/* Holographic Charging Loop Indicator (Simulating UI Screen) */}
        <mesh position={[0, 0.3, 0.06]}>
          <torusGeometry args={[0.3, 0.02, 8, 32]} />
          <meshBasicMaterial 
            color={hovered ? "#00ffb2" : "#7b61ff"} 
            wireframe 
            transparent 
            opacity={0.8} 
          />
        </mesh>

        {/* Glowing Lightning bolt inside phone UI */}
        <mesh position={[0, 0.3, 0.06]} rotation={[0, 0, 0.1]}>
          <cylinderGeometry args={[0.01, 0.08, 0.3, 4]} />
          <meshBasicMaterial color="#00ffb2" transparent opacity={0.9} />
        </mesh>

        {/* Smart Navigation map wireframe dots inside phone UI */}
        <points position={[0, -0.6, 0.06]}>
          <planeGeometry args={[1.0, 0.8, 4, 4]} />
          <pointsMaterial 
            color="#00d1ff" 
            size={0.05} 
            transparent 
            opacity={0.8} 
          />
        </points>

        {/* UI grid background scrolling effect */}
        <mesh position={[0, -0.6, 0.055]} rotation={[0, 0, 0]}>
          <planeGeometry args={[1.1, 0.9]} />
          <meshBasicMaterial 
            color="#0b1120"
            transparent
            opacity={0.5}
            wireframe
          />
        </mesh>
      </group>
    </Float>
  );
}
