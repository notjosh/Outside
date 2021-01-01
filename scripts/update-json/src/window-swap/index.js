import fetchSource from "./fetch-source.js";
import resolve from "./resolve.js";

/**
 * @typedef {Object} WindowSwapSource
 * @property {string} path
 * @property {string} content
 */

const windowSwap = async () => {
  const response = await fetchSource();
  const sources = await resolve(response);

  return sources;
};

export default windowSwap;
