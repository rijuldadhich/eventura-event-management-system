-- More event categories (weddings, birthdays, corporate, conference).
-- Run ONCE in pgAdmin (event_management) AND once in Neon's SQL Editor. Safe to re-run (skips existing events).
-- Venues are real places. Wedding, birthday and corporate clients are fictional. Global Fintech Fest is a real event.

INSERT INTO event (event_name, venue, max_capacity, performer_name, event_date, type_id, client_name, ticket_price, status, description)
SELECT 'Global Fintech Fest 2026','Jio World Centre, Mumbai',NULL::int,NULL,'2026-09-08'::date,
 (SELECT type_id FROM event_type WHERE type_name='Conference'),'Payments Council of India',NULL::numeric,'Completed','Seventh edition, 8-11 Sep 2026.'
WHERE NOT EXISTS (SELECT 1 FROM event WHERE event_name='Global Fintech Fest 2026');

INSERT INTO event (event_name, venue, max_capacity, performer_name, event_date, type_id, client_name, ticket_price, status, description)
SELECT 'Sharma-Kapoor Wedding','Umaid Bhawan Palace, Jodhpur',400,'Live band','2027-02-14'::date,
 (SELECT type_id FROM event_type WHERE type_name='Wedding'),'Sharma Family',0,'Confirmed','Three-day destination wedding.'
WHERE NOT EXISTS (SELECT 1 FROM event WHERE event_name='Sharma-Kapoor Wedding');

INSERT INTO event (event_name, venue, max_capacity, performer_name, event_date, type_id, client_name, ticket_price, status, description)
SELECT 'Iyer-Nair Wedding Reception','The Leela Palace, Udaipur',250,'DJ and live singer','2026-12-27'::date,
 (SELECT type_id FROM event_type WHERE type_name='Wedding'),'Iyer Family',0,'Planning','Lakeside reception dinner.'
WHERE NOT EXISTS (SELECT 1 FROM event WHERE event_name='Iyer-Nair Wedding Reception');

INSERT INTO event (event_name, venue, max_capacity, performer_name, event_date, type_id, client_name, ticket_price, status, description)
SELECT 'Aisha''s 21st Birthday','Taj Lands End, Mumbai',80,'DJ set','2026-11-08'::date,
 (SELECT type_id FROM event_type WHERE type_name='Birthday'),'Aisha Khan',0,'Confirmed','Evening party with dinner.'
WHERE NOT EXISTS (SELECT 1 FROM event WHERE event_name='Aisha''s 21st Birthday');

INSERT INTO event (event_name, venue, max_capacity, performer_name, event_date, type_id, client_name, ticket_price, status, description)
SELECT 'Kabir''s 30th Birthday Bash','The Taj Mahal Palace, Mumbai',120,'Live acoustic act','2026-12-06'::date,
 (SELECT type_id FROM event_type WHERE type_name='Birthday'),'Kabir Singh',0,'Planning','Cocktail evening for close friends and family.'
WHERE NOT EXISTS (SELECT 1 FROM event WHERE event_name='Kabir''s 30th Birthday Bash');

INSERT INTO event (event_name, venue, max_capacity, performer_name, event_date, type_id, client_name, ticket_price, status, description)
SELECT 'Meridian Logistics Annual Day','JW Marriott Mumbai Juhu',300,'Stand-up comedian','2026-11-20'::date,
 (SELECT type_id FROM event_type WHERE type_name='Corporate'),'Meridian Logistics Pvt Ltd',0,'Confirmed','Awards night and gala dinner.'
WHERE NOT EXISTS (SELECT 1 FROM event WHERE event_name='Meridian Logistics Annual Day');

INSERT INTO finance (event_id, manager_name, budget, revenue, expenses, payment_status)
SELECT e.event_id, v.m, v.b, v.r, v.x, v.p FROM (VALUES
 ('Global Fintech Fest 2026','Priya',5000000,5600000,4400000,'Paid'),
 ('Sharma-Kapoor Wedding','Karan',2500000,2800000,2100000,'Partial'),
 ('Iyer-Nair Wedding Reception','Priya',1200000,1300000,950000,'Pending'),
 ('Aisha''s 21st Birthday','Karan',350000,400000,290000,'Partial'),
 ('Kabir''s 30th Birthday Bash','Priya',600000,650000,480000,'Pending'),
 ('Meridian Logistics Annual Day','Karan',900000,1000000,760000,'Partial')
) AS v(n,m,b,r,x,p) JOIN event e ON e.event_name=v.n
ON CONFLICT (event_id) DO NOTHING;

INSERT INTO guest_list (event_id, guest_id)
SELECT e.event_id, g.guest_id FROM event e, guest g
WHERE (e.event_name, g.guest_name) IN (
 ('Sharma-Kapoor Wedding','Aarav'),('Sharma-Kapoor Wedding','Meera'),
 ('Aisha''s 21st Birthday','Isha Patel'),('Aisha''s 21st Birthday','Neha Joshi'),
 ('Kabir''s 30th Birthday Bash','Kabir Singh'),('Kabir''s 30th Birthday Bash','Rohan'),
 ('Meridian Logistics Annual Day','Vikram Rao'),('Meridian Logistics Annual Day','Aarav'),
 ('Global Fintech Fest 2026','Vikram Rao'))
ON CONFLICT DO NOTHING;

INSERT INTO hires_services (event_id, service_id)
SELECT e.event_id, s.service_id FROM event e, services s
WHERE (e.event_name, s.provider_name) IN (
 ('Sharma-Kapoor Wedding','Taj Hotels'),('Sharma-Kapoor Wedding','Wizcraft International Entertainment'),('Sharma-Kapoor Wedding','Furlenco'),
 ('Iyer-Nair Wedding Reception','ITC Hotels'),('Iyer-Nair Wedding Reception','Teamwork Arts'),
 ('Aisha''s 21st Birthday','Haldiram''s'),('Aisha''s 21st Birthday','Furlenco'),
 ('Kabir''s 30th Birthday Bash','Taj Hotels'),('Kabir''s 30th Birthday Bash','Percept Limited'),
 ('Meridian Logistics Annual Day','ITC Hotels'),('Meridian Logistics Annual Day','Godrej Interio'),('Meridian Logistics Annual Day','Reliance Jio'),
 ('Global Fintech Fest 2026','Taj Hotels'),('Global Fintech Fest 2026','Godrej Interio'))
ON CONFLICT DO NOTHING;
