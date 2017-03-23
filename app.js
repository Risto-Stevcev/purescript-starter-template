var express = require('express')
var app = express()

var webpack = require('webpack');
var webpackConfig = require('./webpack.config');
var compiler = webpack(webpackConfig);
 
app.use(require("webpack-dev-middleware")(compiler, {
    noInfo: true, publicPath: webpackConfig.output.publicPath
}))

app.use(require("webpack-hot-middleware")(compiler))

app.use(function(req, res, next) {
  require('./server/index')(req, res, next);
});


var chokidar = require('chokidar')
// Do "hot-reloading" of express stuff on the server
// Throw away cached modules and re-require next time
// Ensure there's no important state in there!
var watcher = chokidar.watch('./server');

watcher.on('ready', function() {
  watcher.on('all', function() {
    console.log("Clearing /server/ module cache from server");
    Object.keys(require.cache).forEach(function(id) {
      if (/[\/\\]server[\/\\]/.test(id)) delete require.cache[id];
    });
  });
})




app.listen(3000, function () {
  console.log('Example app listening on port 3000!')
})
