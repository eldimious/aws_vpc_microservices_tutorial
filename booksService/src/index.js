const http = require('http');
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compress = require('compression')();
const useragent = require('express-useragent');
const fetch = require('node-fetch');

const RECOMMENDATIONS_SERVICE_URL = 'http://internal-alb-recommendations-private-1065112220.eu-west-2.elb.amazonaws.com'
const app = express();
app.use(useragent.express());
app.disable('x-powered-by');
app.use(helmet());
app.use(compress);
app.use(cors());

async function checkStatus(res) {
  if (res.ok) { // res.status >= 200 && res.status < 300
    const response = await res.json();
    return response;
  }
  const response = await res.json();
  const msg = response && response.data && response.data.message
    ? response.data.message
    : res.statusText;
  throw new Error(msg);
}

async function fetchGet({
  url,
  params = {},
  headers = { 'Content-Type': 'application/json' },
}) {
  const res = await fetch(url,
    {
      method: 'get',
      headers,
    });
  if (!res) {
    throw new Error('Response not found when tried to make get request.');
  }
  return checkStatus(res);
}

app.get('/books', async (req, res, next) => {
    return res.status(200).send('Books connected.');
});

app.get('/books/:bookId/recommendations', async (req, res, next) => {
    console.log('try call recommendations ms')
    try {
      const response = await fetchGet({
        url: `${RECOMMENDATIONS_SERVICE_URL}/recommendations`
      });
      console.log('response', response)
      return res.status(200).send(response);
    } catch (error) {
      console.error(`Error on recommendations`, error)
      return res.status(500).send(error);
    }
    
});

const port = process.env.PORT || 5000;

app.listen(port, () => {
    console.log(`Listening on *:${port}`);
});