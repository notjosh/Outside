import fetchSource from "./fetch-source.js";
import resolve from "./resolve.js";

/**
 * @typedef {Object} WindowSwapSource
 * @property {string} path
 * @property {string} content
 */

/**
 * @typedef {Object} Video
 * @property {number} id
 * @property {string} url
 * @property {string} location
 * @property {string} author
 */

/**
 * @returns {Promise<Video[]>}
 */
const windowSwap = async () => {
  const response = await fetchSource();
  const sources = await resolve(response);

  return sources;
};

export default windowSwap;
