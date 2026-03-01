import app, { ensureDbConnected } from '../src/app.js';

export default async function handler(req, res) {
  try {
    await ensureDbConnected();
    // Vercel strips the /api prefix when routing to the api/ directory,
    // but Express routes are mounted at /api/*, so we add it back.
    req.url = `/api${req.url}`;
    return app(req, res);
  } catch (err) {
    console.error(err);
    res.statusCode = 500;
    res.end('Internal server error');
  }
}

