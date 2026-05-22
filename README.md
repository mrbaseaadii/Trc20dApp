# TRON Ecosystem DApp

Automatically create branch, commit changes, and create a pull request workflow for TRON ecosystem development.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/mrbaseaadii/Trc20dApp.git
cd Trc20dApp

# Install dependencies
npm install

# Deploy smart contract
npm run deploy
```

## Project Structure

```
├── contracts/           # Smart contracts (Solidity)
├── src/                 # Frontend/Backend source code
├── tests/               # Test files
├── docs/                # Documentation
├── .github/workflows/   # GitHub Actions workflows
└── README.md
```

## Push PR Workflow

See [PUSH_PR_WORKFLOW.md](./docs/PUSH_PR_WORKFLOW.md) for automated PR creation workflow.

## Technologies

- **Blockchain**: TRON Network
- **Smart Contracts**: Solidity (TRC-20)
- **Frontend**: TypeScript/React
- **Web3**: TronWeb

## Features

✨ **Automated PR Workflow** - Create branches, commits, and pull requests automatically
🔗 **TRC-20 Token Support** - Full TRC-20 token implementation
⚡ **High Performance** - Leverage TRON's 2000+ TPS
🛡️ **Secure** - Built on TRON's proven DPoS consensus
📚 **Well Documented** - Comprehensive guides and examples

## Getting Started with Development

### Prerequisites
- Node.js 16+
- npm or yarn
- Git

### Setup

```bash
# Install dependencies
npm install

# Compile contracts
npm run compile

# Run tests
npm run test

# Start local development node
npm run node:start
```

## Contributing

Please read [CONTRIBUTING.md](./docs/CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Documentation

- [TRON Overview](./docs/TRON_OVERVIEW.md) - Learn about TRON blockchain
- [Push PR Workflow](./docs/PUSH_PR_WORKFLOW.md) - Automated development workflow
- [Contributing Guide](./docs/CONTRIBUTING.md) - How to contribute

## License

MIT License - see LICENSE file for details

## Community

- [TRON Developer Hub](https://developers.tron.network/)
- [TRON GitHub](https://github.com/tronprotocol)
- [TRON Documentation](https://tronprotocol.github.io/)
