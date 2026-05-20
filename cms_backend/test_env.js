console.log('--- ENV KEYS ---');
for (const key of Object.keys(process.env)) {
  if (key.includes('SUPABASE') || key.includes('DB') || key.includes('PASS') || key.includes('DATABASE') || key.includes('PORT')) {
    console.log(`${key}=${process.env[key]}`);
  }
}
console.log('--- DONE ---');
