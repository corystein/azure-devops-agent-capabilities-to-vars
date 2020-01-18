# Agent Capabilties to Variables

Reads values from Hashi Vault key/value engines and create Azure DevOps variables.

## Getting Started

This extension solves a problem common to environments deployed through Azure DevOps. Often, one task or release creates unique values that need to be consumed by other, independent tasks. These subsequent tasks are not part of the same phase, or even the same release, but they need access to the unique values that were created during the original deployment.

### Prerequisites

This extension requires an existing Key Vault in an accessible Azure subscription.

## Configuration

The script can run in one of two modes:

### Sinlge secret retrieval

This will retrieve a single secret from the selected Key Vault by name. It stores the secret in a VSTS variable with a name matching the name of the secret.

### Multiple secret retrieval

This mode will retrieve all Key Vault secrets matching the specified tag values. This is useful for situations where several secrets are needed by subsequent tasks. Setting tag values in a format similar to "Environment=Production" enables the retrieval of all Key Vault secrets with a tag named `Environment` evaluating to `Production`.

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags).

## Authors

- Cory Stein

See also the list of [contributors](https://github.com/corystein/ReadHashiVaultSecrets/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
