import * as path from "path";
import * as assert from "assert";
import * as ttm from "azure-pipelines-task-lib/mock-test";
import * as tl from "azure-pipelines-task-lib/task";

import config from "./config.secret";

function didSetVariable(testRunner: ttm.MockTestRunner, variableName: string, variableValue: string): boolean {
    return testRunner.stdOutContained(`##vso[task.setvariable variable=${variableName};isOutput=false;issecret=false;]${variableValue}`);
}

describe("Sample task tests", function () {

    process.env['TASK_TEST_TRACE'] = '1';
    this.timeout(10000);

    before(function () {
        tl.setVariable("system.teamFoundationCollectionUri", config.systemTeamFoundationCollectionUri);
        tl.setVariable("agent.id", config.agentId);
        tl.setVariable("system.hostType", config.systemHostType);
        tl.setVariable("system.teamProjectId", config.systemTeamProjectId);
        tl.setVariable("build.buildId", config.buildBuildId);
    });

    after(() => {
    });

    it("should succeed with simple inputs", function (done: Mocha.Done) {
        let tp = path.join(__dirname, "success.js");
        let tr: ttm.MockTestRunner = new ttm.MockTestRunner(tp);

        tr.run();
        console.log("Success: " + tr.succeeded);
        assert(tr.succeeded, "should have succeeded");
        assert.equal(tr.warningIssues.length, 0, "should have no warnings");
        assert.equal(tr.errorIssues.length, 0, "should have no errors");
        console.log(tr.stdout);
        assert(tr.stdOutContained("##vso[task.debug]Processing system capabilities"));
        assert(tr.stdOutContained("##vso[task.debug]Processing user capabilities"));
        assert(didSetVariable(tr, "AgentCapabilities.Agent.Name", config.agentName), "should display a system capability");
        assert(didSetVariable(tr, "AgentCapabilities.User.Graphics", config.agentGraphics), "should display a user capability");

        done();
    });

    it("it should fail if tool returns 1", function (done: Mocha.Done) {
        let tp = path.join(__dirname, "failure.js");
        let tr: ttm.MockTestRunner = new ttm.MockTestRunner(tp);

        tr.run();
        console.log("Failure: " + tr.failed);
        assert(tr.failed, "should have failed");
        assert.equal(tr.warningIssues.length, 0, "should have no warnings");
        assert.equal(tr.errorIssues.length, 1, "should have 1 error issue");
        assert.equal(tr.errorIssues[0], "Failed request: (401)", "error issue output");

        done();
    });
});
