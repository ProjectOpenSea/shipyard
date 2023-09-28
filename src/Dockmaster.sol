// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {json} from "lib/shipyard-core/src/onchain/json.sol";
import {svg} from "lib/shipyard-core/src/onchain/svg.sol";
import {LibString} from "solady/utils/LibString.sol";
import {Base64} from "solady/utils/Base64.sol";
import {Solarray} from "solarray/Solarray.sol";
import {Metadata, DisplayType} from "lib/shipyard-core/src/onchain/Metadata.sol";
import {AbstractNFT} from "lib/shipyard-core/src/reference/AbstractNFT.sol";

contract Dockmaster is AbstractNFT {
    using LibString for string;
    using LibString for uint256;

    uint256 public currentId;

    event Hail(string message);

    error UnauthorizedMinter();

    constructor(string memory __name, string memory __symbol) AbstractNFT(__name, __symbol) {
        _name = __name;
        _symbol = __symbol;
        emit Hail(string(abi.encodePacked("Hi Mom! I'm deploying my very own ", __name, " contract!")));
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (tokenId > currentId) {
            // TokenDoesNotExist would be better, this is just to demonstrate a
            // revert with a custom message.
            revert("Token ID does not exist");
        }
        return _stringURI(tokenId);
    }

    function _stringURI(uint256 tokenId) internal view override returns (string memory) {
        return json.objectOf(
            Solarray.strings(
                json.property("name", string.concat("Dockmaster NFT #", tokenId.toString())),
                json.property(
                    "description",
                    string.concat(
                        "This is an NFT on the Dockmaster NFT contract. Its slip number is ", tokenId.toString(), "."
                    )
                ),
                json.property("image", Metadata.base64SvgDataURI(_image(tokenId))),
                _attributes(tokenId)
            )
        );
    }

    function _attributes(uint256 tokenId) internal view override returns (string memory) {
        string[] memory staticTraits = _staticAttributes(tokenId);
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

    /**
     * @notice Helper function to get the static attributes for a given token ID
     * @param tokenId The token ID to get the static attributes for
     */
    function _staticAttributes(uint256 tokenId) internal view virtual override returns (string[] memory) {
        return Solarray.strings(
            Metadata.attribute({traitType: "Slip Number", value: tokenId.toString(), displayType: DisplayType.Number}),
            Metadata.attribute({traitType: "Dock Side", value: tokenId % 2 == 0 ? "North" : "South"})
        );
    }

    function _image(uint256 tokenId) internal pure override returns (string memory) {
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
        // Only the contract owner and addresses with the two leading zeros can
        // mint tokens.
        bool callerFirstByteIsNonZero = (uint256(uint160(msg.sender)) >> (160 - 8)) > 0;
        if (callerFirstByteIsNonZero && msg.sender != owner()) {
            revert UnauthorizedMinter();
        }

        to = to == address(0) ? msg.sender : to;

        unchecked {
            _mint(to, ++currentId);
        }
    }

    function _isOwnerOrApproved(uint256 tokenId, address addr) internal view virtual override returns (bool) {
        return ownerOf(tokenId) == addr || getApproved(tokenId) == addr || isApprovedForAll(ownerOf(tokenId), addr);
    }

    function hail(string memory message) public {
        emit Hail(message);
    }
}
