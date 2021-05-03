import cheerio from 'cheerio';
import fetch from 'node-fetch-retry';
import * as Path from 'path';
import { promises as fsp } from 'fs';
import { fileURLToPath } from 'url';

const ROOT = 'https://www.window-swap.com';

const options = { retry: 3, pause: 1000 };

const fetchSourceNetwork = async () => {
  const response = await fetch(`${ROOT}/Window`, options);
  const body = await response.text();

  const $ = cheerio.load(body);
  const script = $('script')
    .filter((_idx, element) => {
      const src = $(element).attr('src');

      if (src == null) {
        return false;
      }

      return src.match(/main\.[a-fA-F0-9]{20}\.js$/) != null;
    })
    .attr('src');

  if (script == null) {
    throw new Error("Couldn't find main.js script, sry");
  }

  console.log(`found main.js script: ${script}`);

  const normalisedPath = script.startsWith('/') ? script : `/${script}`;

  const sourceURL = `${ROOT}${normalisedPath}`;

  const source = await (await fetch(sourceURL, options)).text();

  return source;
};

const fetchSourceDebug = async () => {
  const __filename = fileURLToPath(import.meta.url);
  const __dirname = Path.dirname(__filename);

  const path = Path.join(__dirname, '../../sample.main.js');
  const content = await fsp.readFile(path, 'utf8');
  return content;
};

const fetchSource = fetchSourceNetwork;

export default fetchSource;
