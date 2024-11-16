const chokidar = require("chokidar");
const fs = require("fs");

const source = "./README.md";
const destination = "./public/README.md";

chokidar.watch(source).on("change", () => {
    fs.copyFileSync(source, destination);
    console.log(`README.md updated at ${new Date().toLocaleTimeString()}`);
});
