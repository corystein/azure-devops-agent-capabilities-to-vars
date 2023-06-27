import * as ma from "azure-pipelines-task-lib/mock-answer";
import * as tmrm from "azure-pipelines-task-lib/mock-run";
import * as path from "path";

import config from "./config.secret";

let taskPath = path.join(__dirname, "..", "index.js");
let tr: tmrm.TaskMockRunner = new tmrm.TaskMockRunner(taskPath);

console.log("run success.ts");
tr.setInput("personalAccessToken", config.personalAccessToken);

tr.run();
