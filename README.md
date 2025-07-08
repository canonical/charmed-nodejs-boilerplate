# charmed-nodejs-boilerplate

Web team charmed NodeJS boilerplate repo

## React with Express Boilerplate

### Architecture

The UI is built using [React](https://react.dev/) and served with [Express](https://expressjs.com/), a Node.js web application framework for building applications in JavaScript. 

### Development

This project can be built in two ways. One is using [taskfile](https://taskfile.dev/installation/) and [docker](https://docker.com/engine/install/), the other is doing it manually using [bun](https://bun.sh/).

#### Taskfile

Prerequisites:
- [taskfile](https://taskfile.dev/installation/)
- [docker](https://docs.docker.com/engine/install/)

To start the development server, run:

```bash
task
```

_Note: You might have to restart the terminal and run the command again if you didn't have `docker` installed before running this command._

Once the server has started, you can visit:
- http://localhost:5173 to see the frontend running with Hot module replacement using Vite.
- http://localhost:8000 to see the express server running reloading enabled


#### bun

Prerequisites:
- [bun](https://bun.sh/docs/installation)
- [nodemon](https://nodemon.io/) (Optional: If you want automatic server restart during development)

Run `bun run serve` to run a server-side rendered version of the app using the [React SSR](https://github.com/canonical/pragma/tree/main/packages/react/ssr) package. You can also run `bun run dev` to run a client-side rendered version of the app using Vite and Vite's Hot module replacement.

##### Build/Serve commands

Two mechanisms for building/serving the application are supported:
- CLI-based: Invoke `@canonical/react-ssr`'s `serve-express` bin script to create an express server.
- Middleware-based: Call `@canonical/react-ssr`'s `serveStream()` function to create a middleware that can be used with an existing express server.

In both cases, the client is built the same way (`bun run build:client`).
The server is built differently depending on the approach:
- CLI-based: The server's SSR rendered module is the entry point. Built with `bun run build:server:cli`, served with `bun run serve:cli`.
- Middleware-based: The server's server script is the entry point. Built with `bun run build:server:middleware`, served with `bun run serve:middleware`.

The current default behavior is to use the middleware-based approach. 
So, `bun run build:server` and `bun run serve` will use the middleware scripts.

In the future, it is intended that the CLI-based approach will be the default, 
and the existing `server.ts` file will be moved to the SSR package as an example.

##### Watch commands

_These commands should not be used alongside `bun run serve`_

You can run `bun run watch:server` and `bun run watch:client` to automatically build client and server code whenever there is a change in the source files.

This should be used alongside [nodemon](https://nodemon.io/) to automatically restart the server when the source files change. After running the watch commands, simply run:

```bash
nodemon --watch dist --ext js --exec "node dist/server/server.js"
```

Your server will start on http://localhost:8000

##### Bin script issues

You may run into an issue where `serve-express` is not linked in `node_modules/.bin` after running `bun i`.
This will result in an error when running `bun run serve:cli`.

To fix this, run `bun i` again.
For more information, see [this documentation](https://github.com/jmuzina/bun-repro/tree/7c9f6eefae2843bc904eabc10db973b56f5e017f/repro/bin-scripts).
