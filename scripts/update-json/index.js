import run from "./src/index.js";

const args = process.argv.slice(2);

if (args.length !== 1) {
  console.error("usage: update-json /path/to/output.json");
  process.exit(1);
}

const outputPath = args[0];

(async () => {
  await run(outputPath);
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
