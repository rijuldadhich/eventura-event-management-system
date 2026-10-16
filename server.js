require('dotenv').config();
const express = require('express'), cors = require('cors'), path = require('path');
const { Pool, types } = require('pg');
types.setTypeParser(1082, v => v); // keep DATE as 'YYYY-MM-DD'
// Hosted DB (Neon/Render) uses one DATABASE_URL + SSL; locally we use the separate .env settings
const pool = new Pool(process.env.DATABASE_URL
  ? { connectionString: process.env.DATABASE_URL, ssl: { rejectUnauthorized: false } }
  : { user: process.env.DB_USER, password: process.env.DB_PASSWORD,
      host: process.env.DB_HOST, port: process.env.DB_PORT, database: process.env.DB_NAME });
const app = express();
app.use(cors(), express.json(), express.static(path.join(__dirname, 'public')));

// table -> [primary key, editable columns]  (whitelist = no SQL injection via names)
const T = {
  event_type: ['type_id', ['type_name']],
  event: ['event_id', ['event_name', 'venue', 'max_capacity', 'performer_name', 'event_date', 'type_id', 'client_name', 'ticket_price', 'status', 'description']],
  guest: ['guest_id', ['guest_name', 'ticket_type', 'email', 'phone']],
  services: ['service_id', ['service_type', 'provider_name', 'contact_phone', 'cost']],
  finance: ['budget_id', ['event_id', 'manager_name', 'budget', 'revenue', 'expenses', 'payment_status']],
};
// many-to-many links: url part -> [junction table, other table, other pk]
const J = { guests: ['guest_list', 'guest', 'guest_id'], services: ['hires_services', 'services', 'service_id'] };
const wrap = fn => (req, res) => fn(req, res).catch(e => res.status(400).json({ error: e.detail || e.message || e.code || String(e) }));
const clean = (cols, body) => cols.map(c => (body[c] === '' || body[c] === undefined ? null : body[c]));

const crypto = require('crypto');
// ---- Admin login: visitors can read (GET); writes need a token. If ADMIN_PASSWORD is unset (local use) everything is open.
app.set('trust proxy', 1);
const ADMIN_PW = process.env.ADMIN_PASSWORD || '';
const sign = exp => crypto.createHmac('sha256', ADMIN_PW).update(String(exp)).digest('hex');
const mkToken = () => { const exp = Date.now() + 12 * 3600e3; return exp + '.' + sign(exp); };
const okToken = t => { if (!t) return false; const [exp, sig] = t.split('.');
  if (!sig || Date.now() > +exp) return false;
  const a = Buffer.from(sig), b = Buffer.from(sign(exp)); return a.length === b.length && crypto.timingSafeEqual(a, b); };
const authed = req => okToken((req.headers.authorization || '').replace('Bearer ', ''));
const tries = {};
app.use('/api', (req, res, next) => {
  if (!ADMIN_PW || req.method === 'GET' || req.path === '/login') return next();
  authed(req) ? next() : res.status(401).json({ error: 'Admin login required' });
});
app.get('/api/me', (req, res) => res.json({ open: !ADMIN_PW, admin: !ADMIN_PW || authed(req) }));
app.post('/api/login', (req, res) => {
  const t = tries[req.ip] = (tries[req.ip] || []).filter(x => Date.now() - x < 9e5);
  if (t.length >= 8) return res.status(429).json({ error: 'Too many attempts. Try again in 15 minutes.' });
  const a = Buffer.from(String(req.body.password || '')), b = Buffer.from(ADMIN_PW);
  if (ADMIN_PW && a.length === b.length && crypto.timingSafeEqual(a, b)) return res.json({ token: mkToken() });
  t.push(Date.now()); res.status(401).json({ error: 'Wrong password' });
});

app.get('/api/overview', wrap(async (req, res) => {
  res.json((await pool.query(`SELECT e.*, t.type_name,
    (SELECT COUNT(*) FROM guest_list l WHERE l.event_id=e.event_id)::int guests,
    (SELECT COUNT(*) FROM hires_services h WHERE h.event_id=e.event_id)::int services,
    f.budget, f.revenue, f.expenses, f.profit, f.payment_status
    FROM event e LEFT JOIN event_type t ON t.type_id=e.type_id LEFT JOIN finance f ON f.event_id=e.event_id
    ORDER BY e.event_date`)).rows);
}));
app.get('/api/stats', wrap(async (req, res) => {
  const q = async s => (await pool.query(s)).rows[0].n;
  res.json({ events: await q('SELECT COUNT(*) n FROM event'), guests: await q('SELECT COUNT(*) n FROM guest'),
    services: await q('SELECT COUNT(*) n FROM services'), profit: await q('SELECT COALESCE(SUM(profit),0) n FROM finance') });
}));

// guests / services attached to one event (JOIN queries)
app.get('/api/event/:id/links', wrap(async (req, res) => {
  const g = await pool.query(`SELECT g.guest_id id, g.guest_name label, g.ticket_type extra FROM guest_list l
    JOIN guest g USING (guest_id) WHERE l.event_id=$1`, [req.params.id]);
  const s = await pool.query(`SELECT s.service_id id, s.provider_name label, s.service_type extra FROM hires_services h
    JOIN services s USING (service_id) WHERE h.event_id=$1`, [req.params.id]);
  res.json({ guests: g.rows, services: s.rows });
}));
app.post('/api/event/:id/:kind', wrap(async (req, res) => {
  const [j, , pk] = J[req.params.kind];
  await pool.query(`INSERT INTO ${j} (event_id, ${pk}) VALUES ($1,$2) ON CONFLICT DO NOTHING`, [req.params.id, req.body.id]);
  res.json({ ok: true });
}));
app.delete('/api/event/:id/:kind/:other', wrap(async (req, res) => {
  const [j, , pk] = J[req.params.kind];
  await pool.query(`DELETE FROM ${j} WHERE event_id=$1 AND ${pk}=$2`, [req.params.id, req.params.other]);
  res.json({ ok: true });
}));

// generic CRUD for the 5 main tables
app.get('/api/:t', wrap(async (req, res) => {
  const [pk] = T[req.params.t];
  res.json((await pool.query(`SELECT * FROM ${req.params.t} ORDER BY ${pk}`)).rows);
}));
app.post('/api/:t', wrap(async (req, res) => {
  const [, cols] = T[req.params.t];
  const ph = cols.map((_, i) => '$' + (i + 1)).join(',');
  res.json((await pool.query(`INSERT INTO ${req.params.t} (${cols}) VALUES (${ph}) RETURNING *`, clean(cols, req.body))).rows[0]);
}));
app.put('/api/:t/:id', wrap(async (req, res) => {
  const [pk, cols] = T[req.params.t];
  const set = cols.map((c, i) => `${c}=$${i + 1}`).join(',');
  res.json((await pool.query(`UPDATE ${req.params.t} SET ${set} WHERE ${pk}=$${cols.length + 1} RETURNING *`,
    [...clean(cols, req.body), req.params.id])).rows[0]);
}));
app.delete('/api/:t/:id', wrap(async (req, res) => {
  await pool.query(`DELETE FROM ${req.params.t} WHERE ${T[req.params.t][0]}=$1`, [req.params.id]);
  res.json({ ok: true });
}));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log('Running at http://localhost:' + PORT));
