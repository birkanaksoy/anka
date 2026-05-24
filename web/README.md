# Anka Web

Static pages to host on GitHub Pages (or any static host) for App Store
submission. App Store Connect requires:

- **Privacy Policy URL** (mandatory)
- **Support URL** (mandatory)
- Marketing URL (optional)

## Deploy

Easiest: GitHub Pages from a `gh-pages` branch or `/docs` folder.

1. Push this repo to GitHub.
2. Settings → Pages → Source: branch `main`, folder `/web`.
3. Wait ~1 min for build. URL will be `https://birkanaksoy.github.io/anka/`
   (or similar).
4. Convert `.md` files to `.html` by enabling Jekyll (default for GitHub
   Pages) — or host the markdown alongside an `index.html` shell.

## Required URLs for App Store Connect

- Privacy Policy: `https://<your-site>/privacy.html`
- Support URL: `https://<your-site>/support.html`
