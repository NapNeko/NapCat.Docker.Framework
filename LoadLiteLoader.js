# From LiteLoader
const fs = require("fs");
const path = require("path");
const package_path = path.join(process.resourcesPath, "app/package.json");
const package = require(package_path);
package.main = "./application/app_launcher/index.js";
fs.writeFileSync(package_path, JSON.stringify(package, null, 4), "utf-8");
require('/opt/QQ/resources/app/LiteLoader/');
require('./application/app_launcher/index.js');
setTimeout(() => {
    package.main = "./LoadLiteLoader.js";
    fs.writeFileSync(package_path, JSON.stringify(package, null, 4), "utf-8");
}, 0);
