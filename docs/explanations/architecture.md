# Architecture Overview

This document explains the high-level architecture of the Charmed Node.js Boilerplate.

## React with Express Boilerplate

The UI is built using [React](https://react.dev/) and served with [Express](https://expressjs.com/), a Node.js web application framework for building applications in JavaScript.

The project implements Server-Side Rendering (SSR) through the [React SSR](https://github.com/canonical/pragma/tree/main/packages/react/ssr) package. There are two primary approaches for building and serving the application's server-side rendered version:

* **CLI-based:** The `cli.ts` rendered module is the entry point. Built with `bun run build:server:cli`, served with `bun run serve:cli`.
* **Middleware-based:** The server's server script is the entry point. Built with `bun run build:server:middleware`, served with `bun run serve:middleware`.

The current default behavior is to use the middleware-based approach. So, `bun run build:server` and `bun run serve` will use the middleware scripts. In the future, it is intended that the CLI-based approach will be the default, and the existing `server.ts` file will be moved to the SSR package as an example.