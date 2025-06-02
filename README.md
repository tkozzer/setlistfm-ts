# 🎶 setlistfm-ts

[![npm](https://img.shields.io/npm/v/setlistfm-ts?color=%2300B2FF&label=npm)](https://www.npmjs.com/package/setlistfm-ts)
[![build](https://github.com/tkozzer/setlistfm-ts/actions/workflows/test.yml/badge.svg)](https://github.com/tkozzer/setlistfm-ts/actions/workflows/test.yml)
[![license](https://img.shields.io/github/license/tkozzer/setlistfm-ts)](./LICENSE)
[![stars](https://img.shields.io/github/stars/tkozzer/setlistfm-ts?style=social)](https://github.com/tkozzer/setlistfm-ts/stargazers)

> A modern, type-safe TypeScript client for the [setlist.fm REST API](https://api.setlist.fm/docs/1.0/index.html).

**setlistfm-ts** provides a lightweight, fully typed interface to the setlist.fm API, enabling easy access to artists, setlists, venues, and more — all in clean, idiomatic TypeScript.

---

## 📦 Installation

```bash
pnpm add setlistfm-ts
# or
npm install setlistfm-ts
# or
yarn add setlistfm-ts
```

---

## ⚙️ Usage

```ts
import { createSetlistFMClient } from "setlistfm-ts";

const client = createSetlistFMClient({
  apiKey: "your-api-key-here",
  userAgent: "your-app-name (your-email@example.com)",
});

// Example: Search artists
const result = await client.artists.search({ artistName: "Radiohead" });

// eslint-disable-next-line no-console
console.log(result.artists);
```

---

## 🧩 Features

✅ Fully typed API responses
✅ Modern `fetch`-based HTTP client
✅ Built-in pagination support
✅ Minimal dependencies
✅ Developer-friendly errors
✅ Tree-shakable modular endpoints

---

## 🔍 Supported Endpoints

| Domain    | Methods                                       |
| --------- | --------------------------------------------- |
| Artists   | `getArtist`, `search`, `getSetlists`          |
| Setlists  | `getSetlist`, `getSetlistVersion`, `search`   |
| Venues    | `getVenue`, `getSetlists`, `search`           |
| Cities    | `search`, `getCityByGeoId`                    |
| Countries | `search`                                      |
| Users     | `getUser`, `getUserAttended`, `getUserEdited` |

> All responses are typed according to the official setlist.fm schema.

---

## 🧪 Testing

Run the full test suite:

```bash
pnpm test
```

Watch mode:

```bash
pnpm test:watch
```

Check code coverage:

```bash
pnpm coverage
```

---

## ✅ Type Checking

Ensure your project stays type-safe:

```bash
pnpm type-check
```

Verbose typecheck:

```bash
pnpm run type-check:verbose
```

---

## 📁 Project Structure

```
src/
├── client.ts           # Entry point for creating the API client
├── endpoints/          # Grouped endpoint handlers (artists, venues, etc.)
├── shared/             # Shared utilities like pagination, errors, metadata
├── utils/              # HTTP logic and logger
├── index.ts            # Public exports
```

---

## 📄 Contributing

We welcome contributions! Please read the [CONTRIBUTING.md](./CONTRIBUTING.md) guide before getting started.

---

## 🛡️ License

[MIT](./LICENSE)

---

## 📫 Contact

Created with 💛 by [@tkozzer](https://github.com/tkozzer)
API documentation: [https://api.setlist.fm/docs](https://api.setlist.fm/docs)

---

## 🌟 Star History

[![Star History Chart](https://api.star-history.com/svg?repos=tkozzer/setlistfm-ts&type=Date)](https://star-history.com/#tkozzer/setlistfm-ts&Date)
