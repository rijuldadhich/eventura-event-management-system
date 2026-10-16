-- Real-world sample data for Eventura.
-- Run ONCE in pgAdmin (event_management) AND once in Neon's SQL Editor (live site).
-- Festival names, dates and venues are real (public info). Costs and finance figures are illustrative.

UPDATE event SET event_name='Lollapalooza India 2027', venue='Mahalaxmi Racecourse, Mumbai', max_capacity=NULL,
  performer_name='Limp Bizkit, 5 Seconds of Summer, Fontaines D.C.', event_date='2027-01-23',
  type_id=(SELECT type_id FROM event_type WHERE type_name='Festival'), client_name='Lollapalooza India',
  ticket_price=4499, status='Confirmed', description='Fifth edition: two days, four stages. Tickets via BookMyShow.' WHERE event_id=1;
UPDATE event SET event_name='Rolling Loud India 2026', venue='Mumbai (venue TBA)', max_capacity=NULL,
  performer_name='Line-up TBA', event_date='2026-12-12',
  type_id=(SELECT type_id FROM event_type WHERE type_name='Concert'), client_name='Rolling Loud',
  ticket_price=NULL, status='Confirmed', description='Two-day hip-hop festival, 12-13 Dec 2026.' WHERE event_id=2;
UPDATE event SET event_name='Sunburn Festival 2026', venue='Mumbai (venue TBA)', max_capacity=NULL,
  performer_name='Line-up TBA', event_date='2026-12-18',
  type_id=(SELECT type_id FROM event_type WHERE type_name='Festival'), client_name='Sunburn',
  ticket_price=NULL, status='Confirmed', description='Two-day electronic music festival, 18-19 Dec 2026.' WHERE event_id=3;
UPDATE event SET event_name='Echoes of Earth 2026', venue='Venue TBA', max_capacity=NULL,
  performer_name='Line-up TBA', event_date='2026-12-05',
  type_id=(SELECT type_id FROM event_type WHERE type_name='Festival'), client_name='Echoes of Earth',
  ticket_price=NULL, status='Confirmed', description='Tenth anniversary of the eco-friendly festival, 5-6 Dec 2026.' WHERE event_id=4;
UPDATE event SET event_name='DGTL India 2026', venue='Venue TBA', max_capacity=NULL,
  performer_name='Nina Kraviz, Stephan Bodzin', event_date=NULL,
  type_id=(SELECT type_id FROM event_type WHERE type_name='Concert'), client_name='DGTL India',
  ticket_price=NULL, status='Planning', description='Electronic music festival. Date to be confirmed.' WHERE event_id=5;
UPDATE event SET event_name='Lollapalooza India 2026', venue='Mahalaxmi Racecourse, Mumbai', max_capacity=NULL,
  performer_name='Linkin Park, Yungblud, Playboi Carti', event_date='2026-01-24',
  type_id=(SELECT type_id FROM event_type WHERE type_name='Festival'), client_name='Lollapalooza India',
  ticket_price=NULL, status='Completed', description='Fourth edition. Linkin Park made their India debut.' WHERE event_id=6;

UPDATE services SET provider_name='Taj Hotels' WHERE service_id=1;
UPDATE services SET provider_name='Wizcraft International Entertainment' WHERE service_id=2;
UPDATE services SET provider_name='Furlenco' WHERE service_id=3;
UPDATE services SET provider_name='Red Bull' WHERE service_id=4;
UPDATE services SET provider_name='Haldiram''s' WHERE service_id=5;
UPDATE services SET provider_name='Teamwork Arts' WHERE service_id=6;
UPDATE services SET contact_phone=NULL;

INSERT INTO services (service_type, provider_name, cost)
SELECT v.t, v.n, v.c FROM (VALUES
  ('Sponsor','Heineken',0),('Sponsor','Spotify',0),('Sponsor','Reliance Jio',0),
  ('Furniture','Godrej Interio',20000),('Food Caterer','ITC Hotels',55000),('Decorator','Percept Limited',28000)
) AS v(t,n,c)
WHERE NOT EXISTS (SELECT 1 FROM services s WHERE s.provider_name=v.n);

INSERT INTO hires_services (event_id, service_id)
SELECT e.event_id, s.service_id FROM event e, services s
WHERE (e.event_name, s.provider_name) IN (
  ('Lollapalooza India 2027','Heineken'),('Lollapalooza India 2027','Spotify'),('Lollapalooza India 2027','Furlenco'),
  ('Rolling Loud India 2026','Red Bull'),('Rolling Loud India 2026','Godrej Interio'),
  ('Sunburn Festival 2026','Heineken'),('Sunburn Festival 2026','ITC Hotels'),
  ('Echoes of Earth 2026','Percept Limited'),('DGTL India 2026','Reliance Jio'))
ON CONFLICT DO NOTHING;
