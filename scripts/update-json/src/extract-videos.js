import { importFromString } from "module-from-string";

/** @typedef {import("./window-swap/index").WindowSwapSource} WindowSwapSource */

/**
 * @typedef {Object} Video
 * @property {number} id
 * @property {string} url
 * @property {string} location
 * @property {string} author
 */

/**
 * @param {WindowSwapSource[]} sources
 * @returns {Promise<Video[]>}
 */
const extractVideos = async (sources) => {
  const videoJs = sources.find((source) => source.path.endsWith("/videos.js"));

  if (videoJs == null) {
    throw new Error("no `videos.js` found in source");
  }

  const imported = await importFromString({ code: videoJs.content });
  const videos = imported.default;

  return videos;
};

export default extractVideos;
