const http = require('http');
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compress = require('compression')();
const useragent = require('express-useragent');
const fetch = require('node-fetch');

const app = express();
app.use(useragent.express());
app.disable('x-powered-by');
app.use(helmet());
app.use(compress);
app.use(cors());

app.get('/books', async (req, res, next) => {
    console.log("Enter books route handler");
    return res.status(200).send('Books connected.');
});

const port = process.env.PORT || 5000;

app.listen(port, () => {
    console.log(`Listening on *:${port}`);
});
