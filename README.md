# Shipyard

Shipyard is a Forge template for smart contract development.


## Installation

Shipyard requires Foundry. You can find specific install instructions [here](https://book.getfoundry.sh/getting-started/installation#using-foundryup).

But most likely, you can install Foundry with the following commands:

```bash
# this installs Foundryup, the Foundry installer and updater
curl -L https://foundry.paradigm.xyz | bash
# follow the onscreen instructions output by the previous command to make Foundryup available in your CLI (or else restart your CLI), then run:
foundryup
```

If you plan on generating coverage reports, you'll need to install [`lcov`](https://github.com/linux-test-project/lcov) as well.

On macOS, you can do this with the following command:

```bash
brew install lcov
```

## Overview
Shipyard comes with some batteries included

- [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts), [Solady](https://github.com/Vectorized/solady), and Shipyard-core smart contracts as dependencies, ready with [`solc` remappings](https://docs.soliditylang.org/en/latest/path-resolution.html#import-remapping) so you can jump into writing your own contracts right away
- `forge fmt` configured as the default formatter for VSCode projects
- Github Actions workflows that run `forge fmt --check` and `forge test` on every push and PR
  - A separate action to automatically fix formatting issues on PRs by commenting `!fix` on the PR
- A pre-configured, but still minimal `foundry.toml` 
  - high optimizer settings by default for gas-efficient smart contracts
  - an explicit `solc` compiler version for reproducible builds
  - no extra injected `solc` metadata for simpler Etherscan verification and [deterministic cross-chain deploys via CREATE2](https://0xfoobar.substack.com/p/vanity-addresses).
  - a separate build profile for CI with increased fuzz runs for quicker local iteration, while still ensuring your contracts are well-tested

## Usage

Shipyard can be used as a starting point or a toolkit in a wide variety of circumstances. Here's a concrete example. To deploy a top of the line NFT contract using shipyard, *TODO*

### Reinitialize Submodules
When working across branches with different dependencies, submodules may need to be reinitialized. Run
```bash
./reinit-submodules
```

### Coverage Reports
Run
```bash
./coverage-report
```

### Useful Aliases

```
alias gm="foundryup"
alias ff="forge fmt"
reinit() {
    git submodule deinit -f .
    git submodule update --init
}
```


## Roadmap

- [x] Configure test.yml to run `forge test` on every push to main and PR
- [x] Add a `forge fmt --check` workflow to the Github Actions
- [x] Add an optional `forge fmt` fix workflow to the Github Actions
- [ ]  Include base dependencies
  - [x] OZ
    - [ ] Pin to version
  - [x] Solady
    - [ ] Pin to version
  - [ ] Shipyard-core (dependent on making public)
- [ ] Include a base cross-chain deploy script
- [ ] Figure out if there's a way we can make `forge verify-contract` more ergonomic
- [ ] Top-level helpers:
  - [x] PRB's `reinit-submodules` script as top-level helper
  - [x] `coverage-report` script as top-level helper
  - [ ] TODO: are there security concerns about these?

Copilot suggests:
- [ ] Additional github actions
  - [ ] Add a `forge deploy` workflow to the Github Actions
  - [ ] Add a `forge verify` workflow to the Github Actions
- [ ] Add a `forge verify` script to the top-level helpers
- [ ] 