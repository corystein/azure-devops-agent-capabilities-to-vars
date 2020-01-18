# Agent Capabilties to Variables

Convert Azure DevOps agent capabilties into pipeline variables.

[![Build Status](https://dev.azure.com/cory-r-stein/azure-devops-agent-capabilities-extension/_apis/build/status/Microsoft.azure-devops-extension-sample)](https://dev.azure.com/cory-r-stein/azure-devops-agent-capabilities-extension/_build/latest?definitionId=7)

## Dependencies

The sample repository depends on a few Azure DevOps packages:

- [azure-devops-extension-sdk](https://github.com/Microsoft/azure-devops-extension-sdk): Required module for Azure DevOps extensions which allows communication between the host page and the extension iframe.
- [azure-devops-extension-api](https://github.com/Microsoft/azure-devops-extension-api): Contains REST client libraries for the various Azure DevOps feature areas.
- [azure-devops-task-lib](https://github.com/microsoft/azure-pipelines-task-lib): Library used for performing task operations.

Some external dependencies:

- `TypeScript` - Samples are written in TypeScript and complied to JavaScript

## Building the sample project

Just run:

    npm run build

This produces a .vsix file which can be uploaded to the [Visual Studio Marketplace](https://marketplace.visualstudio.com/azuredevops)

## Using the extension

The preferred way to get started is to use the `tfx extension init` command which will clone from this sample and prompt you for replacement information (like your publisher id). Just run:

    npm install -g tfx-cli
    tfx extension init

You can also clone the sample project and change the `publisher` property in `azure-devops-extension.json` to your own Marketplace publisher id. Refer to the online [documentation](https://docs.microsoft.com/en-us/azure/devops/extend/publish/overview?view=vsts) for setting up your own publisher and publishing an extension.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags).

## Authors

- Cory Stein

See also the list of [contributors](https://github.com/corystein/ReadHashiVaultSecrets/contributors) who participated in this project.

# Contributing

This project welcomes contributions and suggestions. Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
