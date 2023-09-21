# Changing the behavior of your NFT

Solidity supports inheritance, so instead of tampering with the NFT contracts that come with Shipyard directly, you'll create a new contract and have it inherit from one of the existing contracts. See [Solidity by Example](https://solidity-by-example.org/inheritance/) and [GeeksForGeeks](https://www.geeksforgeeks.org/solidity-inheritance/) for more info on inheritance. The practical takeway is:

- Make a new file in `src/` called `Dockmaster.sol`
- Import `shipyard-core/reference/AbstractNFT.sol:` and inherit from it (`contract Dockmaster is AbstractNFT { ...`)
- Override some functions (`name`, `symbol`, and `tokenURI` are good starting places, e.g. `function name() public pure override returns (string memory) { ...`)
- Add some other fun stuff if you want to

And you'll end up with something that might look like this:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {json} from "shipyard-core/onchain/json.sol";
import {svg} from "shipyard-core/onchain/svg.sol";
import {LibString} from "solady/utils/LibString.sol";
import {Base64} from "solady/utils/Base64.sol";
import {Solarray} from "solarray/Solarray.sol";
import {Metadata, DisplayType} from "shipyard-core/onchain/Metadata.sol";
import {AbstractNFT} from "shipyard-core/reference/AbstractNFT.sol";

contract Dockmaster is AbstractNFT {
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

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return Metadata.base64JsonDataURI(stringURI(tokenId));
    }

    function stringURI(uint256 tokenId) internal view returns (string memory) {
        return json.objectOf(
            Solarray.strings(
                json.property("name", string.concat("Dockmaster NFT #", tokenId.toString())),
                json.property("description", string.concat("My dock has ", tokenId.toString(), " slips.")),
                json.property("image", Metadata.svgDataURI(image(tokenId))),
                _attribute(tokenId)
            )
        );
    }

    function _attribute(uint256 tokenId) internal view returns (string memory) {
        string[] memory staticTraits = Solarray.strings(
            Metadata.attribute({
                traitType: "Slip Number",
                value: tokenId.toString(),
                displayType: DisplayType.Number
            }),
            Metadata.attribute({traitType: "Dock Side", value: tokenId % 2 == 0 ? "North" : "South"})
        );
        string[] memory dynamicTraits = _dynamicAttributes(tokenId);
        string[] memory combined = new string[](staticTraits.length + dynamicTraits.length);
        for (uint256 i = 0; i < staticTraits.length; i++) {
            combined[i] = staticTraits[i];
        }
        for (uint256 i = 0; i < dynamicTraits.length; i++) {
            combined[staticTraits.length + i] = dynamicTraits[i];
        }
        return json.rawProperty("attributes", json.arrayOf(combined));
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

    function isOwnerOrApproved(uint256 tokenId, address addr) internal view virtual override returns (bool) {
        return ownerOf(tokenId) == addr || getApproved(tokenId) == addr || isApprovedForAll(ownerOf(tokenId), addr);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(DynamicTraits, ERC721) returns (bool) {
        return DynamicTraits.supportsInterface(interfaceId) || ERC721.supportsInterface(interfaceId);
    }

    function myVeryOwnFunction() public {
        emit SayHiToMom("Hey Mama!");
    }
}
```

(You'll notice that this looks a lot like shipyard-core's ExampleNFT.sol, but it's special to me now!)

What's great about this is that the `ERC721ConduitPreapproved_Solady` I inheritied via `AbstractNFT` has already handled all the routine ERC721 functionality for me in an almost comically optimized way. So I can burn calories on making something cool, instead of reinventing the nonfungible token wheel. But when I call the `ownerOf` function on my contract, it's going to work as expected.

Now is the time to go wild. Make some wild generative art. Create a novel minting mechanic (only contract deployers are eligible?!). Build an AMM into it. Whatever idea brought you here in the first place, here's where you wire it up. Either bolt it on (like `SayHiToMom`) or override existing functionality (like `tokenURI`). Your NFT is as interesting as you make it.

And because I inherited `AbstractNFT`, which itself inherit `OnchainTraits`, I automatically get functionality that lets me manage on chain traits. So, now I want to add the following trait to token ID 1:

```
{
  "trait_type": "Dock Material"
  "value": "Aluminum"
}
```

To accomplish that, I'll need to first set a trait label by calling `setTraitLabel` with `bytes32(uint256(0x6d6174657269616c))` (the bytes encoded version of "material") as the `traitKey` and the following struct as the `TraitLabel` arg:

```
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

## Next up:

[Deploying for real](Deploying.md)