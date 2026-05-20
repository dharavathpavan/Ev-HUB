"use client";

import React, { useRef, useMemo } from "react";
import { useFrame } from "@react-three/fiber";
import { InstancedMesh, Object3D, Points } from "three";

export default function CityGrid() {
  const meshRef = useRef<InstancedMesh>(null);
  const trafficRef = useRef<Points>(null);

  // Generate building dimensions and grids procedurally
  const buildingData = useMemo(() => {
    const data = [];
    const size = 15; // Grid dimensions (15x15)
    const spacing = 2.5;
    
    for (let x = -size; x <= size; x += 2) {
      for (let z = -size; z <= size; z += 2) {
        // Leave a center hub clear for the EV charger centerpiece
        if (Math.abs(x) < 3 && Math.abs(z) < 3) continue;
        
        // Random buildings parameters
        const height = 1.5 + Math.random() * 6.5;
        const width = 0.6 + Math.random() * 0.8;
        const posX = x * spacing + (Math.random() - 0.5) * 0.5;
        const posZ = z * spacing + (Math.random() - 0.5) * 0.5;
        const color = Math.random() > 0.5 ? "#00d1ff" : "#7b61ff";
        
        data.push({ posX, posZ, height, width, color });
      }
    }
    return data;
  }, []);

  // Update building transformations
  const tempObject = useMemo(() => new Object3D(), []);

  // Set initial building positions
  React.useEffect(() => {
    if (!meshRef.current) return;
    
    buildingData.forEach((building, i) => {
      tempObject.position.set(building.posX, building.height / 2 - 4.5, building.posZ);
      tempObject.scale.set(building.width, building.height, building.width);
      tempObject.updateMatrix();
      meshRef.current!.setMatrixAt(i, tempObject.matrix);
    });
    meshRef.current.instanceMatrix.needsUpdate = true;
  }, [buildingData, tempObject]);

  // Procedural traffic particles scrolling coordinates
  const trafficCount = 180;
  const trafficParticles = useMemo(() => {
    const positions = new Float32Array(trafficCount * 3);
    const speeds = new Float32Array(trafficCount);
    
    for (let i = 0; i < trafficCount; i++) {
      // Traffic flows along streets
      const isEastWest = Math.random() > 0.5;
      const streetIndex = (Math.floor(Math.random() * 12) - 6) * 5;
      
      positions[i * 3] = isEastWest ? (Math.random() - 0.5) * 60 : streetIndex;
      positions[i * 3 + 1] = -4.4; // Ground height
      positions[i * 3 + 2] = isEastWest ? streetIndex : (Math.random() - 0.5) * 60;
      
      speeds[i] = 0.08 + Math.random() * 0.15;
    }
    return { positions, speeds };
  }, []);

  useFrame((state) => {
    const t = state.clock.getElapsedTime();

    // Scroll traffic particles
    if (trafficRef.current) {
      const posAttr = trafficRef.current.geometry.attributes.position;
      const posArray = posAttr.array as Float32Array;
      
      for (let i = 0; i < trafficCount; i++) {
        // Move along roads
        posArray[i * 3] += trafficParticles.speeds[i];
        if (posArray[i * 3] > 30) {
          posArray[i * 3] = -30;
        }
      }
      posAttr.needsUpdate = true;
    }
  });

  return (
    <group>
      {/* Ground Cyber Grid lines */}
      <gridHelper 
        args={[100, 50, "#00d1ff", "#0b1120"]} 
        position={[0, -4.5, 0]} 
      />

      {/* Volumetric Fog floor layer */}
      <mesh position={[0, -4, 0]} rotation={[-Math.PI / 2, 0, 0]}>
        <planeGeometry args={[100, 100]} />
        <meshPhysicalMaterial 
          color="#050816"
          roughness={0.9}
          transparent
          opacity={0.8}
        />
      </mesh>

      {/* Holographic Procedural Buildings */}
      <instancedMesh 
        ref={meshRef} 
        args={[null as any, null as any, buildingData.length]}
      >
        <boxGeometry args={[1, 1, 1]} />
        <meshBasicMaterial 
          color="#0b1120"
          transparent
          opacity={0.45}
          wireframe
        />
      </instancedMesh>

      {/* Moving Traffic / Energy Packets */}
      <points ref={trafficRef}>
        <bufferGeometry>
          <bufferAttribute 
            attach="attributes-position"
            args={[trafficParticles.positions, 3]}
          />
        </bufferGeometry>
        <pointsMaterial 
          color="#00ffb2" 
          size={0.15} 
          sizeAttenuation 
          transparent 
          opacity={0.9} 
        />
      </points>

      {/* Sky Space Stars / Ambient Dust Packets */}
      <points>
        <sphereGeometry args={[45, 12, 12]} />
        <pointsMaterial 
          color="#7b61ff" 
          size={0.08} 
          transparent 
          opacity={0.4} 
        />
      </points>
    </group>
  );
}
