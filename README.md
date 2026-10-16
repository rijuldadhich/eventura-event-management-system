# Eventura: Event Management System

A full-stack event management platform built for a DBMS lab. It manages events, guests, vendors and finances for an event company, with a dark, animated interface.

**Live demo:** https://eventura-event-management-system.onrender.com/

> Hosted on a free plan, so the first load may take about a minute. Visitors get read-only access. Editing needs the admin login.

## Tech stack
- **Frontend:** HTML, CSS and vanilla JavaScript
- **Backend:** Node.js and Express (REST API)
- **Database:** PostgreSQL

## Features
- Dashboard with live stats and a profit-by-event chart
- Events with search, status filters and sorting
- Guest list and vendor booking per event (many-to-many)
- Finance page with revenue, expenses and calculated profit
- Admin login that protects all add, edit and delete actions

## Run locally
1. Create a PostgreSQL database named `event_management`.
2. Run these files in order in the Query Tool: `db/full_setup.sql`, then `db/real_data.sql`, then `db/more_events.sql`.
3. Copy `.env.example` to `.env` and put your Postgres password in it.
4. Run `npm install`, then `npm start`.
5. Open http://localhost:3000

## Admin login
Set an `ADMIN_PASSWORD` environment variable to protect writes. Visitors can view everything, and only the admin can add, edit or delete. If it is not set (for example, local use), the app is open.

## Sample data
- Festival names, dates and venues are real public information (Lollapalooza India, Rolling Loud India, Sunburn, Echoes of Earth, DGTL India, Global Fintech Fest).
- Vendor and sponsor names are real companies, but costs, finance figures and vendor assignments are illustrative sample data for this lab, not real contracts.
- Weddings, birthdays and the corporate annual day use fictional clients at real venues.
- Guest names are fictional.
