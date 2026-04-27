#!/usr/bin/env node
// Enables PostGIS extension on the Railway PostgreSQL instance.
// Run with: railway run node scripts/enable-postgis.js
const { Client } = require('pg');

const client = new Client({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.DATABASE_URL?.includes('railway.internal')
    ? false
    : { rejectUnauthorized: false },
});

client
  .connect()
  .then(() => client.query('CREATE EXTENSION IF NOT EXISTS postgis CASCADE;'))
  .then(({ command }) => {
    console.log(`PostGIS: ${command} — extension ready.`);
    client.end();
  })
  .catch(err => {
    console.error('PostGIS setup failed:', err.message);
    client.end();
    process.exit(1);
  });
