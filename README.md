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
- GitHub Actions workflows that run `forge fmt --check` and `forge test` on every push and PR
  - A separate action to automatically fix formatting issues on PRs by commenting `!fix` on the PR
- A pre-configured, but still minimal `foundry.toml` 
  - high optimizer settings by default for gas-efficient smart contracts
  - an explicit `solc` compiler version for reproducible builds
  - no extra injected `solc` metadata for simpler Etherscan verification and [deterministic cross-chain deploys via CREATE2](https://0xfoobar.substack.com/p/vanity-addresses).
  - a separate build profile for CI with increased fuzz runs for quicker local iteration, while still ensuring your contracts are well-tested

## Usage

Shipyard can be used as a starting point or a toolkit in a wide variety of circumstances. In general, if you're building something NFT related, you're likely to find something useful here. For the sake of exploring some of what Shipyard has to offer in concrete terms, here's a guide on how to deploy an NFT contract.

### Quick Deploy Guide

To deploy an NFT contract to the Goerli testnet, fund an address with 0.25 Goerli ETH, swap in the appropriate values for `<your_key>` and `<your_pk>` in this command, open a terminal window, and run the following:

TODO: update this to do the template thing. And add a bit about staying up to date with the latest.

```
mkdir my-shipyard-based-project &&
cd my-shipyard-based-project &&
curl -L https://foundry.paradigm.xyz | bash &&
foundryup &&
forge init --template projectopensea/shipyard &&
forge build &&
export GOERLI_RPC_URL='https://goerli.blockpi.network/v1/rpc/public &&
export MY_ACTUAL_PK_BE_CAREFUL='<your_pk>' &&
forge create --rpc-url $GOERLI_RPC_URL \
    --private-key $MY_ACTUAL_PK_BE_CAREFUL \
    lib/shipyard-core/src/reference/ExampleNFT.sol:ExampleNFT \
    --constructor-args "Tutorial Example NFT" "TENFT"
```

A quick breakdown of each step follows.

Create a directory, `cd` into it, :
```
mkdir my-shipyard-based-project &&
cd my-shipyard-based-project &&
curl -L https://foundry.paradigm.xyz | bash
```

Install the `foundryup` up command and run it, which in turn installs forge, cast, anvil, and chisel:
```
curl -L https://foundry.paradigm.xyz | bash &&
foundryup
```

Create a new Foundry project based on Shipyard, which also initializes a new git repository.
```
forge init --template projectopensea/shipyard
```

Install dependencies and compile the contracts:
```
forge build
```

Set up your environment variables:
```
export GOERLI_RPC_URL='https://goerli.blockpi.network/v1/rpc/public	 &&
export MY_ACTUAL_PK_BE_CAREFUL='<your_pk>'
```

Run the `forge create` command, which deploys the contract:
```
forge create --rpc-url $GOERLI_RPC_URL \
    --private-key $MY_ACTUAL_PK_BE_CAREFUL \
    lib/shipyard-core/src/reference/ExampleNFT.sol:ExampleNFT \
    --constructor-args "Tutorial Example NFT" "TENFT"
```

See https://book.getfoundry.sh/reference/forge/forge-create for more information on `forge create`.

Running this command deploys the example NFT contract, but it's a good way to check for a properly functioning dev environment. Deploying to mainnet instead of Goerli just requires using a mainnet RPC URL instead of a Goerli RPC URL.

### Custom contract deployment tutorial

See [the full tutorial](shipyardDocs/exampleNFTTutorial/Overview.md) for more detail on modifying the example contract, writing tests, deploying, and more.

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
```


## Roadmap

- [x] Configure test.yml to run `forge test` on every push to main and PR
- [x] Add a `forge fmt --check` workflow to the GitHub Actions
- [x] Add an optional `forge fmt` fix workflow to the GitHub Actions
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
  - [ ] Add a `forge deploy` workflow to the GitHub Actions
  - [ ] Add a `forge verify` workflow to the GitHub Actions
- [ ] Add a `forge verify` script to the top-level helpers
- [ ] 