var express = require('express')
var app = express()

app.get('/foobar', function (req, res) {
  res.set('Access-Control-Allow-Origin', '*')
  res.send({ foo: 'hello', bar: 123, baz: { qux: true } })
})

app.listen(3000, function () {
  console.log('Example app listening on port 3000!')
})
