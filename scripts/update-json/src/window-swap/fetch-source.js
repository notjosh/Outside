import cheerio from "cheerio";
import fetch from "node-fetch-retry";

const ROOT = "https://window-swap.com";

const options = { retry: 3, pause: 1000 };

const fetchSource = async () => {
  const response = await fetch(`${ROOT}/window`, options);
  const body = await response.text();

  const $ = cheerio.load(body);
  const script = $("script")
    .filter((_idx, element) => {
      const src = $(element).attr("src");

      if (src == null) {
        return false;
      }

      return src.match(/main\.[a-fA-F0-9]{8}\.chunk\.js$/) != null;
    })
    .attr("src");

  if (script == null) {
    throw new Error("Couldn't find main.js script, sry");
  }

  console.log(`found main.js script: ${script}`);

  const sourceURL = `${ROOT}${script}`;
  const mapURL = `${ROOT}${script}.map`;

  const source = await (await fetch(sourceURL, options)).text();
  const map = await (await fetch(mapURL, options)).text();

  return {
    source,
    map,
  };
};

export default fetchSource;
