# Google Login App

This repository contains a minimal Node.js application that demonstrates how to integrate Google Sign-In on the frontend and verify ID tokens on the backend using the `google-auth-library`.

## Prerequisites

- [Node.js](https://nodejs.org/) 18 or later
- A Google Cloud project with an OAuth 2.0 Client ID configured for a web application

## Getting Started

1. **Install dependencies**

   ```bash
   npm install
   ```

2. **Set environment variables**

   Export your Google Client ID so the server can verify tokens:

   ```bash
   export GOOGLE_CLIENT_ID="your-google-client-id"
   ```

3. **Update the frontend client ID**

   Replace `YOUR_GOOGLE_CLIENT_ID` inside `index.html` with the same client ID value.

4. **Run the application**

   ```bash
   npm start
   ```

   The server will start on [http://localhost:3000](http://localhost:3000).

## How It Works

- The frontend uses [Google Identity Services](https://developers.google.com/identity/gsi/web) to render a Google Sign-In button and receive ID tokens when the user logs in.
- The token is sent to the Express backend (`/api/auth/google`) where it is verified with `OAuth2Client.verifyIdToken`.
- After verification, the decoded payload (user profile information) is returned to the browser.

## Deployment on Render

This project is ready for deployment on [Render](https://render.com/):

1. Push the repository to GitHub (for example, `google-login-app`).
2. Create a new **Web Service** on Render and connect the repository.
3. Choose the **Free** plan, set the environment to **Node**, and use the default build and start commands from `render.yaml`.
4. Add an environment variable `GOOGLE_CLIENT_ID` under **Environment**.
5. Deploy the service.

Refer to `render.yaml` for the configuration Render will use.

## Security Notes

- Never expose your Google Client Secret in the frontend.
- Always verify the ID token on the server before trusting the user identity.
- Consider adding HTTPS, CSRF protection, and stricter CORS settings for production use.
