const express = require('express');
const path = require('path');
const fs = require('fs');
const rateLimit = require('express-rate-limit');
const { OAuth2Client } = require('google-auth-library');

const app = express();
const PORT = process.env.PORT || 3000;
const CLIENT_ID = process.env.GOOGLE_CLIENT_ID;

if (!CLIENT_ID) {
  console.warn('GOOGLE_CLIENT_ID is not set. Token verification will fail.');
}

const oauthClient = new OAuth2Client(CLIENT_ID);

app.enable('trust proxy');

const limiter = rateLimit({
  windowMs: 60 * 1000,
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
});

app.use(limiter);

app.use((req, res, next) => {
  if (process.env.NODE_ENV === 'production' && !req.secure) {
    const host = req.headers.host;
    if (host) {
      return res.redirect(307, `https://${host}${req.originalUrl}`);
    }
  }
  next();
});

app.use(express.json({ limit: '1mb' }));

const indexPath = path.join(__dirname, 'index.html');
const indexTemplate = fs.readFileSync(indexPath, 'utf8');

app.get('/', (_req, res) => {
  const config = JSON.stringify({ GOOGLE_CLIENT_ID: CLIENT_ID || '' });
  const html = indexTemplate.replace('__ENV_CONFIG__', config);
  res.type('html').send(html);
});

app.post('/api/auth/google', async (req, res) => {
  const { credential } = req.body || {};

  if (!credential) {
    return res.status(400).json({ error: 'Missing credential in request body' });
  }

  if (!CLIENT_ID) {
    return res
      .status(500)
      .json({ error: 'GOOGLE_CLIENT_ID environment variable is not configured' });
  }

  try {
    const ticket = await oauthClient.verifyIdToken({
      idToken: credential,
      audience: CLIENT_ID,
    });

    const payload = ticket.getPayload();

    if (!payload) {
      throw new Error('Empty payload returned by Google');
    }

    const { name = null, email = null, picture = null, sub = null } = payload;

    return res.json({
      profile: { name, email, picture, sub },
    });
  } catch (error) {
    console.error('Failed to verify Google ID token:', error);
    return res.status(401).json({ error: 'Invalid or expired ID token' });
  }
});

app.listen(PORT, () => {
  console.log(`Server listening on http://localhost:${PORT}`);
});
