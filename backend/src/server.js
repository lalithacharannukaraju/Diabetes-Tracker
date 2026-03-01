import app, { ensureDbConnected } from './app.js';

const PORT = process.env.PORT || 4000;

ensureDbConnected()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`Server listening on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error('MongoDB connection error', err);
    process.exit(1);
  });
