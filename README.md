# purescript-starter-template

## Usage

```bash
$ npm install
$ npm run pulp:watch
```

And in a separate terminal, start the webpack dev server:

```bash
$ npm run hmr
```

And in yet another terminal, start the dummy server to server the ajax response:

```bash
$ node server/index.js
```

- The webpack dev server will startup when you run `npm run hmr`
- Go to the server location at `http://localhost:8080/`
- Try the routing for the two pages, the 'Counter List' page and the 'Ajax Example' page
- The 'Ajax Example' page will show 'Loading...' before the resource is fetched. You might need to turn on throttling so 
  that the connection is slow enough to see it
- Play around with the counters in the 'Counter List' page to generate some state
- Update the button text in `Counter.purs` to say 'Increment!' and save
- The `pulp:watch` command you ran will trigger a rebuild, and the webpack dev server will be triggered after the 
  modules get rebuilt
- Observe in the browser that your code has updated without a refresh and the state you left the app in is still preserved!

NOTE: This is a trivial hot module reloading example, but for more complex apps you will likely need to dispose resources 
that keep some internal state or side effects, such as listeners. You can do this with `module.hot.dispose`/`module.hot.addDisposeHandler`
