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

app.use('/users', async (req, res, next) => {
    return res.status(200).send('Users connected.');
});

const port = process.env.PORT || 3000;

app.listen(port, () => {
    console.log(`Listening on *:${port}`);
});