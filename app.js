const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send(`Hello World v3, ${new Date().toLocaleTimeString()}`);
});

app.listen(3000, () => {
  console.log('Server is running on port 3000');
});
