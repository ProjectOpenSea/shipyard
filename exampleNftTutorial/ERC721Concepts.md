# Getting your head into the code

Feel free to skip this section if you've already read about ERC-721 or perused the code on your own.

There's nothing like going straight to the source: [https://eips.ethereum.org/EIPS/eip-721#specification](https://eips.ethereum.org/EIPS/eip-721#specification). The ERC-721 spec outlines the bare minimum interface and behavior that a contract needs to implement in order to be recognized and treated as an ERC-721 contract by the rest of the web 3 ecosystem (such as OpenSea, block explorers, etc.). There are only a half dozen operative "MUST"s in there, so we've got a lot of leeway. Eventually, we're going to deploy a snazzy, gas-optimized ERC721 with some bonus features. But for now, let's take a look at the stock version, [OpenZeppelin's example ERC721](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol)

OpenZeppelin's contracts show a straightforward, battle-tested, minimal implementation of the ERC-721 spec. For example, the ERC-721 spec states that `safeTransferFrom` "Throws if `_from` is not the current owner."  And we can see that the required functionality is implemented on [lines 148-150](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol#L148-L150) of OpenZeppelin's ERC721:

```solidity
        if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }
```

Take a pass through the spec and identify in the OZ code where each requirement is met. It's elegant, simple, and ingenious. NFTs are great!

But we can build something even better.

[EVM](https://ethereum.org/en/developers/docs/evm/) based blockchains use the concept of [gas](https://ethereum.org/en/developers/docs/gas/) to address spam and infinite loops. This means that every operation on chain costs real money. So, by making changes at the level of implementation details in your smart contract, you can save your users real money. A penny here and a buck there add up to a lot!  

Compare [Solady's `_ownerOf`](https://github.com/Vectorized/solady/blob/main/src/tokens/ERC721.sol#L369-L378) with [OpenZeppelin's](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol#L168-L178). OZ's relies on the functionality that comes for free with solidity, which is convenient, but less gas efficient. Solady's implementation uses assembly to trim the gas costs down, but it comes at the expense of readability.

But don't get nervous! This is just a quick tour through the code we're going to be working on top of. You'll be able to make a custom, interesting NFT with maximally optimized guts without having to get elbows deep in `mstore`s. You won't even have to twiddle any bits by hand unless you want to.

Let's get to it.

## Next up: 

[Setting up your environment](EnvironmentSetup.md)