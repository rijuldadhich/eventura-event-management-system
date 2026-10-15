-- Run ONCE in pgAdmin Query Tool (after setup.sql). Adds richer columns + more sample data.
ALTER TABLE event ADD COLUMN client_name VARCHAR(100), ADD COLUMN description TEXT,
  ADD COLUMN ticket_price NUMERIC(10,2) DEFAULT 0,
  ADD COLUMN status VARCHAR(20) DEFAULT 'Planning' CHECK (status IN ('Planning','Confirmed','Completed','Cancelled'));
ALTER TABLE guest ADD COLUMN email VARCHAR(100), ADD COLUMN phone VARCHAR(20);
ALTER TABLE services ADD COLUMN contact_phone VARCHAR(20), ADD COLUMN cost NUMERIC(10,2) DEFAULT 0;
ALTER TABLE finance DROP COLUMN profit;
ALTER TABLE finance ADD COLUMN revenue NUMERIC(12,2) DEFAULT 0, ADD COLUMN expenses NUMERIC(12,2) DEFAULT 0,
  ADD COLUMN payment_status VARCHAR(20) DEFAULT 'Pending' CHECK (payment_status IN ('Pending','Partial','Paid'));
ALTER TABLE finance ADD COLUMN profit NUMERIC(12,2) GENERATED ALWAYS AS (revenue - expenses) STORED;

INSERT INTO event_type (type_name) VALUES ('Corporate'),('Birthday'),('Festival') ON CONFLICT DO NOTHING;
UPDATE event SET client_name='Neon Live Pvt Ltd', ticket_price=1500, status='Confirmed', description='Open-air music night' WHERE event_id=1;
UPDATE event SET client_name='Sharma Family', ticket_price=0, status='Planning', description='Two-day wedding celebration' WHERE event_id=2;
INSERT INTO event (event_name, venue, max_capacity, performer_name, event_date, type_id, client_name, ticket_price, status, description) VALUES
('TechSummit 2026','Convention Centre',800,'Dr. Anita Rao','2026-11-05',3,'Zenith Corp',2500,'Confirmed','Annual industry conference'),
('Aisha''s 21st','Skyline Lounge',120,'DJ Ray','2026-10-25',5,'Aisha Khan',0,'Confirmed','Rooftop birthday party'),
('Diwali Mela','Riverside Grounds',2000,'Folk Troupe','2026-10-30',6,'City Council',300,'Planning','Community festival'),
('Spring Gala','Grand Hall',300,'String Quartet','2026-09-12',4,'Rotary Club',5000,'Completed','Charity dinner');
UPDATE finance SET budget=100000, revenue=185000, expenses=120000, payment_status='Partial' WHERE event_id=1;
UPDATE finance SET budget=150000, revenue=170000, expenses=130000, payment_status='Paid' WHERE event_id=2;
UPDATE guest SET email='aarav@mail.com', phone='9820011111' WHERE guest_id=1;
UPDATE guest SET email='meera@mail.com', phone='9820022222' WHERE guest_id=2;
UPDATE guest SET email='rohan@mail.com', phone='9820033333' WHERE guest_id=3;
INSERT INTO guest (guest_name, ticket_type, email, phone) VALUES
('Isha Patel','VIP','isha@mail.com','9820044444'),('Kabir Singh','General','kabir@mail.com','9820055555'),
('Neha Joshi','Student','neha@mail.com','9820066666'),('Vikram Rao','VIP','vikram@mail.com','9820077777');
UPDATE services SET contact_phone='9700011111', cost=45000 WHERE service_id=1;
UPDATE services SET contact_phone='9700022222', cost=30000 WHERE service_id=2;
UPDATE services SET contact_phone='9700033333', cost=15000 WHERE service_id=3;
UPDATE services SET contact_phone='9700044444', cost=0 WHERE service_id=4;
INSERT INTO services (service_type, provider_name, contact_phone, cost) VALUES
('Food Caterer','Spice Route Catering','9700055555',60000),('Decorator','Petal & Co','9700066666',25000);
INSERT INTO guest_list VALUES (3,4),(3,5),(4,6),(5,7),(6,1),(6,4) ON CONFLICT DO NOTHING;
INSERT INTO hires_services VALUES (3,5),(3,4),(4,6),(5,5),(6,2),(6,6) ON CONFLICT DO NOTHING;
INSERT INTO finance (event_id, manager_name, budget, revenue, expenses, payment_status) VALUES
(3,'Priya',400000,520000,350000,'Partial'),(4,'Karan',80000,95000,70000,'Paid'),
(5,'Priya',200000,150000,90000,'Pending'),(6,'Karan',250000,300000,210000,'Paid');
