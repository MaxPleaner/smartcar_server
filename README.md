## Smartcar coding challenge (server component)

This is the server component which uses [the GM API component](https://github.com/MaxPleaner/smartcar_challenge)

Installation / Usage:

1. clone the repo
2. Make sure `node` and `coffeescript` are installed globally
3. Run `npm install`
4. Run `coffee server.coffee` to start the server on port 1234
  - you can override the port via command line options (i.e. `--port 3000`)
  - you can alternatively use `nodemon server.coffee` (nodemon should be installed globally) to rerun the server when files change
  -
Tests are [here](the GM API component](https://github.com/MaxPleaner/smartcar_challenge)

## How code is organized

- [server.coffee](./server.coffee) is the main server file, which has all the routes.
- [package.json](./package.json) lists NPM dependencies and makes this component available as a module
- [compile.sh](./compile.sh) will compile `server.coffee` to `dist/server.js`