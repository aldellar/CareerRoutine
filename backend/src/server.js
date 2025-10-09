
import express from 'express';
import yaml from 'js-yaml';
import swaggerUi from 'swagger-ui-express';
import fs from 'fs';
import path from 'node:path';
import OpenApiValidator from 'express-openapi-validator';
import {fileURLToPath} from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

import systemRoutes from './routes/systemRoutes.js';
import dataRoutes from './routes/dataRoutes.js';

const app = express();
app.use(express.json());
app.use(express.urlencoded({extended: false}));

const apiSpec = path.join(__dirname, '../api/openapi.yaml');

const apidoc = yaml.load(fs.readFileSync(apiSpec, 'utf8'));
app.use('/docs', swaggerUi.serve, swaggerUi.setup(apidoc));

const port = process.env.PORT || 8081;

apidoc.servers = [
  { url: `http://${process.env.HOST || '0.0.0.0'}:${port}` }
];

app.use(
    OpenApiValidator.middleware({
      apiSpec: apiSpec,
      validateRequests: true,
      validateResponses: true,
    }),
);

app.use((err, req, res, next) => {
  res.status(err.status == 415 ? 400 : err.status).json({
    message: err.message,
    errors: err.errors,
    status: err.status == 415 ? 400 : err.status,
  });
});

app.use('/', systemRoutes);
app.use('/data', dataRoutes);

app.listen(port, '0.0.0.0', () => {
  const host = process.env.HOST || '0.0.0.0';
  console.log(`API Testing UI is at: http://${host}:${port}/docs/`);
});
