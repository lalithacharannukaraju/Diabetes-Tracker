import app, { ensureDbConnected } from '../src/app.js';

export default async function handler(req, res) {
  try {
    await ensureDbConnected();
    return app(req, res);
  } catch (err) {
    console.error(err);
    res.statusCode = 500;
    res.end('Internal server error');
  }
}

