import fetch from 'node-fetch';
import asyncPool from 'tiny-async-pool';

const INTERVAL = 0;
const CONCURRENCY = 5;

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
  const results = await asyncPool(CONCURRENCY, array, async (arg) =>
    (await predicate(arg)) == null ? null : arg
  );

  return results.filter((value) => value != null);
};

/**
 * @param {Video} video
 * @returns {Promise<boolean>}
 */
const isValidVideo = async (video) => {
  const url = `https://player.vimeo.com/video/${video.url}/config?`;
  const params = new URLSearchParams(video.params);

  console.log(`checking: ${url + params}: ${video.author} - ${video.location}`);

  let ok = false;
  let status = '<unknown>';

  try {
    const response = await fetch(url + params);
    ok = response.ok;
    status = `${response.status} ${response.statusText}`;
  } catch (error) {
    console.log(error);
  }

  console.log(`...${url + params}: ${ok ? '✅' : '❌'} ${status}`);

  // don't spam the endpoint
  await sleep(INTERVAL);

  return ok;
};

/**
 * @param {Video[]} videos
 * @returns {Promise<Video[]>}
 */
const filterValid = async (videos) => {
  const out = await filter(videos, isValidVideo);

  return out;
};

export default filterValid;
