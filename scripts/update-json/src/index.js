import { promises as fs } from 'fs';

import windowSwap from './window-swap/index.js';
import filterValid from './vimeo/filter-valid.js';

const run = async (outputPath) => {
  if (outputPath == null) {
    throw new Error('output path must be supplied');
  }

  try {
    const videos = await windowSwap();

    if (videos == null) {
      throw new Error('no videos found from site source');
    }

    console.log(`found ${videos.length} videos`);

    const validVideos = await filterValid(videos);

    const out = {
      timestamp: new Date().toISOString(),
      videos: validVideos.sort((lhs, rhs) => lhs.id - rhs.id),
    };

    // sort object keys for nicer diffs
    const replacer = (key, value) =>
      value instanceof Object && !(value instanceof Array)
        ? Object.keys(value)
            .sort((lhs, rhs) => lhs.localeCompare(rhs))
            .reduce(
              (sorted, key) => {
                sorted[key] = value[key];
                return sorted;
              },
              {
                // ID always first
                id: value.id,

                // known keys from our code come next
                author: value.author,
                location: value.location,
                params: value.params,
                service: value.service,
                url: value.url,
              }
            )
        : value;

    const string = JSON.stringify(out, replacer, 2);

    await fs.writeFile(outputPath, string);

    console.log(`exported videos to: ${outputPath}`);
  } catch (e) {
    console.log('sources: error');
    console.error(e);
  }
};

export default run;
