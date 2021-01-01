import { promisify } from "util";
import sourceMapResolve from "source-map-resolve";

const resolveSourceMapAsync = promisify(sourceMapResolve.resolveSourceMap);
const resolveSourcesAsync = promisify(sourceMapResolve.resolveSources);

/** @typedef {import("./index").WindowSwapSource} WindowSwapSource */

/**
 * @param {Object} input
 * @param {string} input.source
 * @param {string} input.map
 * @returns {WindowSwapSource[]|null}
 */
const resolve = async (input) => {
  if (input == null || input.source == null || input.map == null) {
    return null;
  }

  const { map, sourcesRelativeTo } = await resolveSourceMapAsync(
    input.source,
    "/",
    (uri, cb) => {
      console.log("reading from uri:", { uri });

      cb(null, input.map);
    }
  );

  const { sourcesResolved, sourcesContent } = await resolveSourcesAsync(
    map,
    sourcesRelativeTo,
    (_uri, cb) => {
      cb(null, "");
    }
  );

  const sources = sourcesResolved.map((path, index) => ({
    path,
    content: sourcesContent[index],
  }));

  return sources;
};

export default resolve;
