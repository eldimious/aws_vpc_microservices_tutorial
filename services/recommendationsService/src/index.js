const http = require('http');
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compress = require('compression')();
const useragent = require('express-useragent');

const app = express();
app.use(useragent.express());
app.disable('x-powered-by');
app.use(helmet());
app.use(compress);
app.use(cors());

app.get('/recommendations', async (req, res, next) => {
  return res.status(200).send({
    data: 'Recommendation connected.'
  });
});

app.get('/recommendations/health-check', async (req, res, next) => {
  return res.status(200).send('ok');
});

const port = process.env.PORT || 3333;

app.listen(port, () => {
    console.log(`Listening on *:${port}`);
});
