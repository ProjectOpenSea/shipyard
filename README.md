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

Shipyard can be used as a starting point or a toolkit in a wide variety of circumstances. In general, if you're building something NFT related, you're likely to find something useful here. For the sake of exploring some of what Shipyard has to offer in concrete terms, here's a guide on how to deploy an NFT contract.

### Deploying an NFT Contract with Shipyard

This mini-tutorial will assume that you're already a software engineer, but that you're not yet steeped in the ways of web 3.  If you're trying to learn both at the same time, huge props, but it's probably advisable to start with a more structured and guided tutorial, such as [CryptoZombies](https://cryptozombies.io/).

TODO: table of contents
TODO: spellcheck

#### Getting your head into the code

There's nothing like going straight to the source: [https://eips.ethereum.org/EIPS/eip-721#specification](https://eips.ethereum.org/EIPS/eip-721#specification).  The ERC-721 spec outlines the bare minimum interface and behavior that a contract needs to implement in order to be recognized and treated as an ERC-721 contract by the rest of the web 3 ecosystem (such as OpenSea, Etherscan, etc.).  There's only a half dozen operative "MUST"s in there, so we've got a lot of leeway.  Eventually, we're going to deploy a snazzy, gas-optimized ERC721 with some bonus features. But for now, let's take a look at the stock version, [OpenZeppelin's example ERC721](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol) 

TODO: update with links within the repo thorughout.

OpenZeppelin's contracts show a straightforward, battle-tested, minimal implementation of the ERC-721 spec. For example, the ERC-721 spec states that `safeTransferFrom` "Throws if `_from` is not the current owner."  And we can see that the required functionality is implemented on [lines 148-150](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol#L148-L150) of OpenZeppelin's ERC721:

```
        if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }
```

Take a pass through the spec and identify in the OZ code where each requirement is met. It's elegant, simple, and ingenious. NFTs are great!

But we can build something even better.  

[EVM](https://ethereum.org/en/developers/docs/evm/) based blockchains use the concept of [gas](https://ethereum.org/en/developers/docs/gas/) to address spam and infinite loops. This means that every operation on chain costs real money. So, by making changes at the level of implementation details in your smart contract, you can save your users real money. A penny here and a buck there add up to a lot!  

Compare [Solady's `_ownerOf`](https://github.com/Vectorized/solady/blob/main/src/tokens/ERC721.sol#L369-L378) with [OpenZeppelin's](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol#L168-L178). OZ's relies on the functionality that comes for free with solidity, which is convenient, but less gas efficient. Solady's implementation uses assembly to trim the gas costs down, but it comes at the expense of readability.

But don't get nervous! This is just a quick tour through the code we're going to be working on top of.  You'll be able to make a custom, interesting NFT with maximally optimized guts without having to get elbows deep in `mstore`s.  You won't even have to twiddle any bits by hand unless you want to. Let's get to it.

#### Setting up your environment

First off, check out [Foundrybook's take on deploying](https://book.getfoundry.sh/forge/deploying). That will get you a good deal of the way there.

And then check out the `sample.env` file. You can see how the two would come together into a command like this:

```
forge create --rpc-url $GOERLI_RPC \
    --private-key $MY_ACTUAL_PK_BE_CAREFUL \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --verify \
    src/reference/ExampleNFT.sol:ExampleNFT
```

I mean, you could just make a `.env` file based on the sample, source it (`. .env` or `source .env`), and run that command. You could be an NFT creator in like the next 10 minutes. Forge would compile the necessary files (`Compiler run successful!`), log the address you deployed from (`Deployer: <your_address>`), show you the transaction hash of the deployment transaction (`Transaction hash: 0x...`), and then automatically verify it on Etherscan. You'd have a contract to your name. You'd be able to link your friends and coworkers to it on Etherscan. You could even yeet a contract straight to mainnet just by switching out `$GOERLI_RPC` with `$ETH_RPC`!

But hold out, it's not time yet! Or go ahead, we're not the deploy police. But you'll definitely feel better about the contract if you run some test, make some innovative or at least fun changes, write some new tests, run them some more, and *then* deploy. Or do it right now. It's comforting to know that it actually works before you invest real time. For real, doing something at your terminal and then seeing a corresponding change on a block explorer is magical. Do it! Or don't. Either way.

Anyway, let's take a look at the portion of the `.env` file that's pertinent to testing. `FOUNDRY_VERBOSITY=3` is like running your tests with the `-vvv` flag all the time. It's usually the exact sweet spot.  When tests pass, they're not going to spam you with stack traces, but when they fail, you'll likely have all the info you need to debug.

`FOUNDRY_FUZZ_RUNS=128` means that [fuzz tests](https://book.getfoundry.sh/forge/fuzz-testing) will run 128 times each, with Foundry picking randomish numbers for each run.  

#### Running tests

To run the stock tests, you can just do `forge test`.  Forge will notice if you're missing dependencies and install them.  It'll compile the contracts if you haven't already done `forge build`.  And then it'll run the tests.  You'll to see stuff like `[PASS] testName() (gas: 28286)` near the end, showing you which tests passed and which failed.  And the last line will be something like `Ran 1 test suites: 23 tests passed, 0 failed, 0 skipped (23 total tests)`.

You can try tampering with some tests or with some of the code they cover to trigger failures. In that case, you'll see something like `[FAIL. Reason: Assertion failed. Counterexample: ...` (for fuzz tests) or `[FAIL. Reason: Assertion failed.]` for normal tests. If you do something the EVM can't cope with at all, you might see `EVM: Revert` `[FAIL. Reason: Index out of bounds]` or something like `[FAIL. Reason: Arithmetic over/underflow]`.  You can speed up your cycles by targeting specific tests with [`--match-path` or `match-test`](https://book.getfoundry.sh/forge/tests?highlight=match-path#tests).  And if you're making tweaks steadily and you want Forge to keep running the tests continually without you pressing up and enter over and over, add the `--watch` flag.  For example, `forge test --match-test testSomething --watch -vvvv` will run just the test named `testSomething`, it'll rerun every time you save, and it'll show traces for both failing and passing tests.

#### Changing the behavior of your NFT

Solidity supports inheritance, so instead of tampering with the NFT contracts that come with Shipyard directly, you'll create a new contract and have it inherit from one of the existing contracts. See [Solidity by Example](https://solidity-by-example.org/inheritance/) and [GeeksForGeeks](https://www.geeksforgeeks.org/solidity-inheritance/) for more info on inheritance. The practical takeway is:

- Make a new file in `src/tokens/erc721/` called `Dockmaster.sol`
- Inherit from `src/tokens/erc721/ERC721ConduitPreapproved_Solady.sol:ERC721ConduitPreapproved_Solady`
- Override some functions (`name`, `symbol`, and `tokenURI` are good starting places)
- Add some other fun stuff if you want

TODO: wire up the dynamic traits stuff

And you'll end up with something that looks a lot like this:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC721ConduitPreapproved_Solady} from "src/tokens/erc721/ERC721ConduitPreapproved_Solady.sol";
import {json} from "shipyard-core/onchain/json.sol";
import {svg} from "shipyard-core/onchain/svg.sol";
import {LibString} from "solady/utils/LibString.sol";
import {Base64} from "solady/utils/Base64.sol";
import {Solarray} from "solarray/Solarray.sol";
import {Metadata, DisplayType} from "shipyard-core/onchain/Metadata.sol";

contract Dockmaster is ERC721ConduitPreapproved_Solady {
    using LibString for string;
    using LibString for uint256;

    uint256 currentId;

    event SayHiToMom(string message);

    constructor() {
        emit SayHiToMom("Hi Mom!");
    }

    function name() public pure override returns (string memory) {
        return "Dockmaster";
    }

    function symbol() public pure override returns (string memory) {
        return "DOCK";
    }

    function tokenURI(uint256 tokenId) public pure override returns (string memory) {
        return Metadata.base64JsonDataURI(stringURI(tokenId));
    }

    function stringURI(uint256 tokenId) internal pure returns (string memory) {
        return json.objectOf(
            Solarray.strings(
                json.property("name", string.concat("Dockmaster NFT #", tokenId.toString())),
                json.property("description", string.concat("My dock has ", tokenId.toString(), " slips.")),
                json.property("image", Metadata.svgDataURI(image(tokenId))),
                _attribute(tokenId)
            )
        );
    }

    function _attribute(uint256 tokenId) internal pure returns (string memory) {
        return json.rawProperty(
            "attributes",
            json.arrayOf(
                Solarray.strings(
                    Metadata.attribute({
                        traitType: "Slip Number",
                        value: tokenId.toString(),
                        displayType: DisplayType.Number
                    }),
                    Metadata.attribute({traitType: "Dock Side", value: tokenId % 2 == 0 ? "North" : "South"})
                )
            )
        );
    }

    function image(uint256 tokenId) internal pure returns (string memory) {
        return svg.top({
            props: string.concat(svg.prop("width", "500"), svg.prop("height", "500")),
            children: string.concat(
                svg.rect({
                    props: string.concat(svg.prop("width", "500"), svg.prop("height", "500"), svg.prop("fill", "lightgray"))
                }),
                svg.text({
                    props: string.concat(
                        svg.prop("x", "50%"),
                        svg.prop("y", "50%"),
                        svg.prop("dominant-baseline", "middle"),
                        svg.prop("text-anchor", "middle"),
                        svg.prop("font-size", "48"),
                        svg.prop("fill", "black")
                        ),
                    children: string.concat("You're looking at slip #", tokenId.toString())
                })
                )
        });
    }

    function mint(address to) public {
        unchecked {
            _mint(to, ++currentId);
        }
    }

    function myVeryOwnFunction() public {
        emit SayHiToMom("Hey Mama!");
    }
}
```

(You'll notice that this looks a lot like ExampleNFT.sol, but it's special to me now!)

What's great about this is that the `ERC721ConduitPreapproved_Solady` I inheritied has already handled all the routine ERC721 functionality for me in an almost comically optimized way. So I can burn calories on making something cool, instead of reinventing the nonfungible token wheel. But when I call the `ownerOf` function on my contract, it's going to work as expected.

So now is the time to go wild. Make some crazy generative art. Create a novel minting mechanic (only contract deployers are eligible?!). Build an AMM into it. Whatever idea brought you here in the first place, here's where you wire it up. Either bolt it on or override existing functionality. Your NFT is as interesting as you make it.

#### Testing your custom functionality in Forge

Just as ExampleNFT.sol served as a great template for my custom contract, ExampleNFT.t.sol is going to be a great template for my custom tests (once it's written lol). TODO

#### Testing your custom functionality with ffi

TODO: adapt this to this context.

##### Running ffi tests.

Currently, the ffi tests are the only way to test the output of ExampleNFT's tokenURI response. More options soon™.

In general, it's wise to be especially wary of ffi code. In the words of the Foundrybook, "It is generally advised to use this cheat code as a last resort, and to not enable it by default, as anyone who can change the tests of a project will be able to execute arbitrary commands on devices that run the tests."

##### Environment configuration

To run the ffi tests locally, set `FOUNDRY_PROFILE='ffi'` in your `.env` file, and then source the `.env` file. This will permit Forge to make foreign calls (`ffi = true`) and read and write within the `./test-ffi/` directory. It also tells Forge to run the tests in the `./test-ffi/` directory instead of the tests in the `./test/` directory, which are run by default. Check out the `foundry.toml` file, where all of this and more is configured.

Both the local profile and the CI profile for the ffi tests use a low number of fuzz runs, because the ffi lifecycle is slow. Before yeeting a project to mainnet, it's advisable to crank up the number of fuzz runs to increase the likelihood of catching an issue. It'll take more time, but it increases the likelihood of catching an issue.

##### Expected local behavior

The `ExampleNFT.t.sol` file will call `ExampleNFT.sol`'s `tokenURI` function, decode the base64 encoded response, write the decoded version to `./test-ffi/tmp/temp.json`, and then call the `process_json.js` file a few times to get string values. If the expected values and the actual values match, the test will pass. A `temp.json` file will be left behind. You can ignore it or delete it; Forge makes a new one on the fly if it's not there. And it's ignored in the `.gitignore` file, so there's no need to worry about pushing cruft or top secret metadata to a shared/public repo.

##### Expected CI behavior

When a PR is opened or when a new commit is pushed, Github runs a series of actions defined in the files in `.github/workflows/*.yml`. The normal Forge tests and linting are set up in `test.yml`. The ffi tests are set up in `test-ffi.yml`. Forks of this repository can safely disregard it or if it's not necessary, remove it entirely.

#### Deploying for real

OK, here's the big moment.  Now that you've gotten your head into ERC721s, set up your environment, ran some tests, made your custom contract, ran some more tests, and then ran even more tests, it's time to deploy. The process is basically identical to the example above.

```
forge create --rpc-url $ETH_RPC \
    --private-key $MY_ACTUAL_PK_BE_CAREFUL \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --verify \
    src/tokens/erc721/Dockmaster.sol:Dockmaster
```

Forge compiles (or skips compiling bc you've got a clean build from all those tests you ran, right? right?),  logs the address you deployed from, shows the transaction hash of the deployment transaction, and then automatically verifies the contract on Etherscan. It's definitely worth configuring your Etherscan API key and getting verification over with at this phase. It's way easier to do in Forge than in the Etherscan UI.

And that's it! Now go shill it on twitter or whatever.


### Useful Resources

[The Foundrybook](https://book.getfoundry.sh/) contains a lot of useful information for working in the context of a Foundry project. But some of the best stuff isn't explicitly written out in it. When you're using cast, or when you're asking yoruself "I wonder if there's a way to do <some web 3 thing>" it's worth running `cast --help` or looking straight at `Vm.sol`'s cheatcodes.

If you're trying to parse out the assembly in the Solady-based contracts, [https://www.evm.codes/](https://www.evm.codes/) might offer some help.

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