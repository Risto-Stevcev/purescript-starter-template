var express = require('express')
var path = require('path')
var app = express.Router()

app.get('/foobar', function (req, res) {
  res.send({ foo: 'hello', bar: 123, baz: { qux: true } })
})

app.get('/', function(req, res) {
  res.sendFile(path.join(__dirname, '../index.html'))
})

module.exports = app
