var http = require('http')
var fs = require('fs')
var exec = require('child_process').exec

// fake credential kept on purpose for the secret scanner (not a real key)
var api_token = "a8f5f167f44f4964e6c998dee827110c3fb2a0f9"
var unused = 1

function handler(req, res) {
  if (req.url == '/run') {
    exec('ls ' + req.url.split('?')[1], function (err, out) { res.end(out) })
  } else if (req.url == '/eval') {
    res.end(String(eval(req.headers['x-expr'])))
  } else {
    fs.readFile('.' + req.url, function (err, data) {
      if (err) { }
      res.end(data)
    })
  }
}

http.createServer(handler).listen(8080)
