'use strict';

import { randomUUID } from 'crypto';
import express from 'express';

const app = express();
const port = process.env.APP_PORT;
const host = '0.0.0.0';
const hostid = randomUUID();

app.get('/', (req, res) => {
  console.log("Request received");
  console.log(process.env);
  console.log({hostid});
  res.send('Hello World from inside the rock! \n\n' + JSON.stringify(process.env, null, 2) + "\n\n" + hostid + "\n\n");
});

app.listen(port, host, () => {
  console.log(`Express Application Running on http://${host}:${port}`);
});