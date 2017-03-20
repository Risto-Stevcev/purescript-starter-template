# purescript-starter-template

## Usage

```bash
$ npm install
$ npm run pulp:watch
```

And in a separate terminal, type:

```bash
$ npm run hmr
```

- The webpack dev server will startup when you run `npm run hmr`
- Go to the server location at `http://localhost:8080/`
- Try the routing for the two pages, the 'Counter List' page and the 'Ajax Example' stub page
- Play around with the counters in the 'Counter List' page to generate some state
- Update the button text in `Counter.purs` to say 'Increment!' and save
- The `pulp:watch` command you ran will trigger a rebuild, and the webpack dev server will be triggered after the 
  modules get rebuilt
- Observe in the browser that your code has updated without a refresh and the state you left the app in is still preserved!
