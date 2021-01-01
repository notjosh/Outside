import { promises as fs } from "fs";

import windowSwap from "./window-swap/index.js";
import extractVideos from "./extract-videos.js";
import filterValid from "./vimeo/filter-valid.js";

const run = async (outputPath) => {
  if (outputPath == null) {
    throw new Error("output path must be supplied");
  }

  try {
    const sources = await windowSwap();

    if (sources == null) {
      throw new Error("no sources found from sourcemap");
    }

    const videos = await extractVideos(sources);

    if (videos == null) {
      throw new Error("no videos found in exports");
    }

    console.log(`found ${videos.length} videos`);

    const out = {
      timestamp: new Date().toISOString(),
      videos: await filterValid(videos),
    };

    await fs.writeFile(outputPath, JSON.stringify(out, null, 2));

    console.log(`exported videos to: ${outputPath}`);
  } catch (e) {
    console.log("sources: error");
    console.error(e);
  }
};

export default run;
