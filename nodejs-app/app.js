const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  const env = process.env.APP_ENV || 'unknown';
  res.send(`Hello from Node.js App in ${env} environment!`);
});

app.listen(port, () => {
  console.log(`Node.js app listening at http://0.0.0.0:${port}`);
});
