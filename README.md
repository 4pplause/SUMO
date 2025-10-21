# Google Login App

This repository contains a minimal Node.js application that demonstrates how to integrate Google Sign-In on the frontend and verify ID tokens on the backend using the `google-auth-library`.

## Prerequisites

- [Node.js](https://nodejs.org/) **18 or later** (the runtime is enforced through the `engines` field and Render configuration)
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

   The server will inject this value into the frontend automatically—no manual edits to `index.html` are required.

3. **Run the application**

   ```bash
   npm start
   ```

   The server will start on [http://localhost:3000](http://localhost:3000).

## How It Works

- The frontend uses [Google Identity Services](https://developers.google.com/identity/gsi/web) to render a Google Sign-In button once the server-provided `window.GOOGLE_CLIENT_ID` value is available.
- The token is sent to the Express backend (`/api/auth/google`) where it is verified with `OAuth2Client.verifyIdToken`.
- After verification, the backend returns only the essential profile fields (`name`, `email`, `picture`, and `sub`).

## Deployment on Render

This project is ready for deployment on [Render](https://render.com/):

1. Push the repository to GitHub (for example, `google-login-app`).
2. Create a new **Web Service** on Render and connect the repository.
3. Choose the **Free** plan, set the environment to **Node**, and use the default build and start commands from `render.yaml`.
4. The provided `render.yaml` pins the service to Node.js 18 and declares a `GOOGLE_CLIENT_ID` environment variable—add the value in the Render dashboard before deploying.
5. Deploy the service.

Refer to `render.yaml` for the configuration Render will use.

## Injecting `GOOGLE_CLIENT_ID` Dynamically

When the server receives a request for `/`, it injects a JSON blob containing the `GOOGLE_CLIENT_ID` into `index.html`. The frontend reads this configuration via `window.GOOGLE_CLIENT_ID` before initializing Google Identity Services. This means the same build can be promoted across environments without editing the HTML file.

## Troubleshooting

- **Missing client ID:** If you see “GOOGLE_CLIENT_ID is not configured…”, confirm the environment variable is defined locally or in your hosting provider.
- **Invalid or expired session:** A “Your Google session is invalid or has expired” message indicates the credential sent from Google is no longer valid. Ask the user to sign in again.
- **Configuration parsing errors:** Errors about loading configuration usually mean the HTML response was cached or modified before reaching the browser. Clear caches or redeploy to ensure the inline JSON is up to date.

## Security Notes

- Never expose your Google Client Secret in the frontend.
- Always verify the ID token on the server before trusting the user identity.
- Production deployments should keep HTTPS enabled, consider additional CSRF protections, and tune the included rate limiter as appropriate for expected traffic.
