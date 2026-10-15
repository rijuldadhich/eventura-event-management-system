# Eventura: Event Management System
DBMS lab project. Node.js + Express backend, PostgreSQL database, vanilla JS frontend.

## Run locally
1. Create a PostgreSQL database named `event_management` and run `db/full_setup.sql` in it (once).
2. Copy `.env.example` to `.env` and put your Postgres password in it.
3. `npm install` then `npm start`, then open http://localhost:3000

## Features
Events, guests, vendors and finance management; per-event guest list and vendor booking (many-to-many); dashboard with live stats and profit chart.
