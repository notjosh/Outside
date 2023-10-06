import fetchSource from './fetch-source.js';
import resolve from './resolve.js';

/**
 * @typedef {Object} WindowSwapSource
 * @property {string} path
 * @property {string} content
 */

/**
 * @typedef {Object} VideoParams
 * @property {string} h
 */

/**
 * @typedef {Object} Video
 * @property {string} id
 * @property {string} location
 * @property {string} author
 * @property {string} service
 * @property {VideoParams} params
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
