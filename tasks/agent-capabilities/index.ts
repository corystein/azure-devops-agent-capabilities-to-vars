import task = require('azure-pipelines-task-lib/task');
import * as azureDevOps from 'azure-devops-node-api';
import { TaskAgent } from 'azure-devops-node-api/interfaces/TaskAgentInterfaces';

async function run() {
    try {
        let token = task.getInput('personalAccessToken', true);

        let collectionUri = task.getVariable('system.teamFoundationCollectionUri');

        let authHandler = azureDevOps.getPersonalAccessTokenHandler(token);

        let connection = new azureDevOps.WebApi(collectionUri, authHandler);
        
        let agentId = Number(task.getVariable('agent.id'));

        let hostType = task.getVariable('system.hostType');

        let poolId: number;

        switch (hostType) {
            case 'build': {
                let projectId = task.getVariable('system.teamProjectId');
                let buildId: number = Number(task.getVariable('build.buildId'));
                let buildApi = await connection.getBuildApi();
                let build = await buildApi.getBuild(buildId, projectId);
                poolId = build.queue.pool.id;
                break;
            }
            case 'release': {
                break;
            }
            case 'deployment': {
                let deploymentGroupId: number = Number(task.getVariable('agent.deploymentGroupId'));
                task.debug(`deploymentGroupId: ${deploymentGroupId}`);
                let projectId = task.getVariable('system.teamProjectId');
                task.debug(`projectId: ${projectId}`);
                let agentApi = await connection.getTaskAgentApi();
                task.debug(`agentApi: ${JSON.stringify(agentApi)}`);
                let deploymentGroup = await agentApi.getDeploymentGroup(projectId, deploymentGroupId);
                task.debug(`deploymentGroup: ${JSON.stringify(deploymentGroup)}`);
                poolId = deploymentGroup.pool.id;
                task.debug(`poolId: ${poolId}`);
                break;
            }
            default:{
                throw new Error(`Unsupported host type ${hostType}`);
            }
        }

        let agent: TaskAgent;
        try{            
            let agentApi = await connection.getTaskAgentApi();
            agent = await agentApi.getAgent(poolId, agentId, true);
            task.debug(`agent: ${JSON.stringify(agent)}`);
        }
        catch(err){
            task.debug(`Error getting agent: ${err}`);
            throw new Error('Invalid personal access token. Make sure the token is valid and active.');
        }

        console.log('Agent capability variables and values. Format: variable=value');
        console.log();

        // TODO: remove in next major version
        function setTaskVariablesLegacy(capabilities: any) {
            const keys = Object.keys(capabilities);

            for (const key of keys) {
                const formattedKey = `AgentCapabilities.${key}`;
                const value = capabilities[key];
                task.setVariable(formattedKey, value);
                console.log(`${formattedKey}=${value}`);
            }
        }

        function setTaskVariables(kind: string, capabilities: any) {
            const keys = Object.keys(capabilities);

            for (const key of keys) {
                const formattedKey = `AgentCapabilities.${kind}.${key}`;
                const value = capabilities[key];
                task.setVariable(formattedKey, value);
                console.log(`${formattedKey}=${value}`);
            }
        }

        if (agent.systemCapabilities){
            task.debug('Processing system capabilities');
            setTaskVariablesLegacy(agent.systemCapabilities); // TODO: remove in next major version
            setTaskVariables('System', agent.systemCapabilities);
        }
        else{
            task.debug('No system capabilities found');
        }

        if (agent.userCapabilities){
            task.debug('Processing user capabilities');
            setTaskVariables('User', agent.userCapabilities);
        }
        else{
            task.debug('No user capabilities found');
        }

        task.setResult(task.TaskResult.Succeeded, 'Succeeded');
    }
    catch (err) {
        task.setResult(task.TaskResult.Failed, err.message);
    }
}

run();