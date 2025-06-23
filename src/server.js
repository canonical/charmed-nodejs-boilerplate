'use strict';

import express from 'express';
const app = express();
const port = 8080;
const host = '0.0.0.0';

app.get('/', (req, res) => {
  console.log("Request received");
  console.log(process.env);
  res.send('Hello World from inside the rock! \n\n' + JSON.stringify(process.env) + "\n\n");
});

app.listen(port, host, () => {
  console.log(`Express Application Running on http://${host}:${port}`);
});