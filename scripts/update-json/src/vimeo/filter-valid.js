import fetch from "node-fetch";

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

/** @typedef {import("../extract-videos").Video} Video */

/**
 * @callback predicateCallback
 * @param {Video} video
 */

/**
 * a sequential async filter - sort of like `Promise.all`, but that'd be fully concurrent & dangerous for API limits
 *
 * @param {Video[]} array
 * @param {predicateCallback} predicate
 * @returns {Promise<Video[]>}
 */
const filter = async (array, predicate) => {
  const results = [];

  for (const item of array) {
    results.push(await predicate(item));
  }

  return array.filter((_v, index) => results[index]);
};

/**
 * @param {Video[]} videos
 * @returns {Promise<Video[]>}
 */
const filterValid = async (videos) => {
  const out = await filter(videos, async (video) => {
    const url = `https://player.vimeo.com/video/${video.url}/config`;

    console.log(
      `checking: #${video.id} (${url}): ${video.author} - ${video.location}`
    );

    let ok = false;

    try {
      const response = await fetch(url);
      ok = response.ok;
    } catch (error) {
      console.log(error);
    }

    console.log(`...${ok ? "✅" : "❌"}`);

    // don't spam the endpoint
    await sleep(300);

    return ok;
  });

  return out;
};

export default filterValid;
