# purescript-starter-template

## Usage

Install dependencies

```bash
$ npm install
```

Run the purescript watcher to trigger a compile on file changes

```
$ npm run pulp:watch
```

And in a separate terminal, start the server:

```bash
$ npm start
```

- The server has hot reloading middleware baked in
- Go to the server location at `http://localhost:3000/`
  - Try the routing for the two pages, the 'Counter List' page and the 'Ajax Example' page
  - The 'Ajax Example' page will show 'Loading...' before the resource is fetched. You might need to turn on throttling so 
    that the connection is slow enough to see it
  - Play around with the counters in the 'Counter List' page to generate some state
  - Update the button text in `Counter.purs` to say 'Increment!' and save
  - The `pulp:watch` command you ran will trigger a rebuild, and the webpack dev server will be triggered after the 
    modules get rebuilt
  - Observe in the browser that your code has updated without a refresh and the state you left the app in is still preserved!
- Now try updating the response from the `/foobar` endpoint
  - Observe that the server didn't have to restart to serve the new response from the endpoint
- You can play around with the time travel debugger via your dev tools console. It is available as a global variable 
  called `travel`
  - To read the current state of the breadcrumb and pointer, run `travel.read()`. The pointer reflects the index of 
    your current position in the breadcrumb
  - Use `travel.prev()` and `travel.next()` to traverse back and forth in time
  - If you execute an action, the breadcrumb will update providing the action and the new app state, and the pointer will 
    point to the end of the breadcrumb if it wasn't pointing there before

NOTE: This is a trivial hot module reloading example, but for more complex apps you will likely need to dispose resources 
that keep some internal state or side effects, such as listeners. You can do this with `module.hot.dispose`/`module.hot.addDisposeHandler`
