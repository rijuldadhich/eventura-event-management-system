Eventura: Event Management System
DBMS lab project. Node.js + Express backend, PostgreSQL database, vanilla JS frontend.
Live demo: https://eventura-event-management-system.onrender.com/ (free hosting, so the first load may take about a minute). Visitors get read-only access; editing needs the admin login.
Run locally
Create a PostgreSQL database named `event_management` and run `db/full_setup.sql` in it (once).
Copy `.env.example` to `.env` and put your Postgres password in it.
`npm install` then `npm start`, then open http://localhost:3000
Features
Events, guests, vendors and finance management; per-event guest list and vendor booking (many-to-many); dashboard with live stats and profit chart.
Admin login
Set an `ADMIN_PASSWORD` environment variable to protect writes (visitors can view, only the admin can add/edit/delete). If it is not set (e.g. local use), the app is open.
Sample data
Festival names, dates and venues are real public information (Lollapalooza India, Rolling Loud India, Sunburn, Echoes of Earth, DGTL India). Vendor and sponsor names are real companies, but costs, finance figures and which vendor works on which event are illustrative sample data for this DBMS lab, not real contracts. Weddings, birthdays and the corporate annual day use fictional clients at real venues. Global Fintech Fest is a real event, but its finance figures here are illustrative. Guest names are fictional.
