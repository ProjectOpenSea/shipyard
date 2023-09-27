# Deploying an NFT Contract with Shipyard

This mini-tutorial will assume that you're already a software engineer, but that you're not yet steeped in the ways of web 3. If you're trying to learn both at the same time, huge props, but it's probably advisable to start with a more structured and guided tutorial, such as [CryptoZombies](https://cryptozombies.io/).


## Deploying Tutorial Table of Contents

- [Getting your head into the code](ERC721Concepts.md)
- [Setting up your environment](EnvironmentSetup.md)
- [Running tests](Testing.md)
- [Changing the behavior of your NFT](CustomNFTFunctionality.md)
- [Deploying for real](Deploying.md)

## Useful Resources

[The Foundrybook](https://book.getfoundry.sh/) contains a lot of useful information for working in the context of a Foundry project. But some of the best stuff isn't explicitly written out in it. When you're using cast, or when you're asking yourself "I wonder if there's a way to do <some web 3 thing>" it's worth running `cast --help` or looking straight at `Vm.sol`'s cheatcodes.

If you're trying to parse out the assembly in the Solady-based contracts, [https://www.evm.codes/](https://www.evm.codes/) might offer some help.