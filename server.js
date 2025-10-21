const express = require('express');
const path = require('path');
const { OAuth2Client } = require('google-auth-library');

const app = express();
const PORT = process.env.PORT || 3000;
const CLIENT_ID = process.env.GOOGLE_CLIENT_ID;

if (!CLIENT_ID) {
  console.warn('GOOGLE_CLIENT_ID is not set. Token verification will fail.');
}

const oauthClient = new OAuth2Client(CLIENT_ID);

app.use(express.json({ limit: '1mb' }));

app.get('/', (_req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
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

    return res.json({ payload });
  } catch (error) {
    console.error('Failed to verify Google ID token:', error);
    return res.status(401).json({ error: 'Invalid or expired ID token' });
  }
});

app.listen(PORT, () => {
  console.log(`Server listening on http://localhost:${PORT}`);
});
