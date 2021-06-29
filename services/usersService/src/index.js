const http = require('http');
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compress = require('compression')();
const useragent = require('express-useragent');
const {
  recommendationsService: recommendationsServiceConfig
} = require('./configuration');
const {
  fetchGet
} = require('./common/utils');

const app = express();
app.use(useragent.express());
app.disable('x-powered-by');
app.use(helmet());
app.use(compress);
app.use(cors());

app.get('/users', async (req, res, next) => {
  console.log("Enter users route handler");
  return res.status(200).send({
    data: 'Users connected.'
  });
});

app.get('/users/:id/recommendations', async (req, res, next) => {
  console.log("Enter users recommendations route handler", recommendationsServiceConfig.baseUrl);
  try {
    const response = await fetchGet({
      url: `${recommendationsServiceConfig.baseUrl}/recommendations`
    });
    console.log('response', response)
    return res.status(200).send(response);
  } catch (error) {
    console.error(`Error on recommendations`, error)
    return res.status(500).send(error);
  }
});

app.get('/users/health-check', async (req, res, next) => {
  return res.status(200).send('ok');
});

const port = process.env.PORT || 3000;

app.listen(port, () => {
    console.log(`Listening on *:${port}`);
});
