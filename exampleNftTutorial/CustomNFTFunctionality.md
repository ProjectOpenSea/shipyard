# Changing the behavior of your NFT

Solidity supports inheritance, so instead of tampering with the NFT contracts that come with Shipyard directly, you'll create a new contract and have it inherit from one of the existing contracts. See [Solidity by Example](https://solidity-by-example.org/inheritance/) and [GeeksForGeeks](https://www.geeksforgeeks.org/solidity-inheritance/) for more info on inheritance. The practical takeway is:

- Make a new file in `src/` called `MyVeryOwnNFT.sol`
- Import `shipyard-core/reference/AbstractNFT.sol:` and inherit from it (`contract MyVeryOwnNFT is AbstractNFT { ...`)
- Override some functions (`name`, `symbol`, and `tokenURI` are good starting places, e.g. `function name() public pure override returns (string memory) { ...`)
- Add some other fun stuff if you want to

And you'll end up with something that might look like [Dockmaster](../../src/Dockmaster.sol), but with your own special touches.

(You'll notice that Dockmaster itself looks a lot like [shipyard-core's ExampleNFT.sol](https://github.com/ProjectOpenSea/shipyard-core/blob/main/src/reference/ExampleNFT.sol), but it's special to me now, because I've made changes!)

What's great about this inheritance pattern is that the `ERC721ConduitPreapproved_Solady` we inheritied via `AbstractNFT` has already handled all the routine ERC721 functionality for us in an almost comically optimized way. So we can burn calories on making something cool, instead of reinventing the nonfungible token wheel. But when someone calls the `ownerOf` function on my contract, it's going to work as expected.

And because I inherited `AbstractNFT`, which itself inherit `OnchainTraits`, I automatically get functionality that lets me manage on chain traits. So, now I want to add the following trait to token ID 1:

```json
{
  "trait_type": "Dock Material"
  "value": "Aluminum"
}
```

To accomplish that, I'll need to first set a trait label by calling `setTraitLabel` with `bytes32(uint256(0x6d6174657269616c))` (the bytes encoded version of "material") as the `traitKey` and the following struct as the `TraitLabel` arg:

```solidity
TraitLabel memory myFirstDynamicTrait {(
    fullTraitKey: myFirstTraitKeyString,
    traitLabel: myFirstLabelString,
    acceptableValues: myFirstArrayOfAcceptableValuesStrings,
    fullTraitValues: myFirstArrayOfFullTraitValues,
    displayType: myFirstDisplayTypeEnumValue,
    editors: myFirstEditorsValue;
)}
```

Look at `TraitLabelLib.sol` to get a better sense of how to set those values up.

Then I just call `setTrait` with `bytes32(uint256(0x6d6174657269616c))` as the `traitKey` argument, `1` as the `tokenID` argument, and `bytes32(uint256(<bytes32_value_of_my_trait>))` as the `trait` argument. The `_setTrait` function will store the value (`_traits[tokenId][traitKey] = value;`) and emit a `TraitUpdated` event, to put the world on notice that token ID 1 now has a new trait on it.

See also the [SetTraiLabel](../script/SetTraitLabel.s.sol) and [SetTrait](../script/SetTrait.s.sol) scripts, or the dynamic trait tests in the [Dockmaster ffi test](../test-ffi/Dockmaster.t.sol).

Now is the time to go wild. Make some wild generative art. Create a novel minting mechanic (only contract deployers are eligible?!). Build an AMM into it. Whatever idea brought you here in the first place, here's where you wire it up. Either bolt it on (like `Hail`) or override existing functionality (like `tokenURI`). Your NFT is as interesting as you make it.

## Next up:

[Deploying for real](Deploying.md)