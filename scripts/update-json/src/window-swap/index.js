import fetchSource from './fetch-source.js';
import resolve from './resolve.js';

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
  const sources = resolve(response);

  return sources.map((source) => ({
    ...source,
    location: source.location.trim(),
    author: source.author.trim(),
  }));
};

export default windowSwap;
