var express = require('express');
var app = express();
app.get('/', function (req, res) {
  res.send('Welcome to DFLY service');
});
app.listen(8080, function () {
  console.log('Dfly is listening on port 8080');
});
