var express = require('express')
var app = express()

var path = require('path')

var webpack = require('webpack');
var webpackConfig = require('../webpack.config');
var compiler = webpack(webpackConfig);
 
app.use(require("webpack-dev-middleware")(compiler, {
    noInfo: true, publicPath: webpackConfig.output.publicPath
}))

app.use(require("webpack-hot-middleware")(compiler))

app.get('/foobar', function (req, res) {
  res.set('Access-Control-Allow-Origin', '*')
  res.send({ foo: 'hello', bar: 123, baz: { qux: true } })
})

app.get('/', function(req, res) {
  res.sendFile(path.join(__dirname, '../index.html'))
})

app.listen(3000, function () {
  console.log('Example app listening on port 3000!')
})
