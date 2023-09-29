// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {LibString} from "solady/utils/LibString.sol";
import {Base64} from "solady/utils/Base64.sol";
import {Solarray} from "solarray/Solarray.sol";
import {json} from "lib/shipyard-core/src/onchain/json.sol";
import {svg} from "lib/shipyard-core/src/onchain/svg.sol";
import {Metadata, DisplayType} from "lib/shipyard-core/src/onchain/Metadata.sol";
import {AbstractNFT} from "lib/shipyard-core/src/reference/AbstractNFT.sol";

/**
 * @title Dockmaster
 * @dev This is an example NFT contract that demonstrates how to use the
 *      AbstractNFT contract to create an NFT with onchain metadata and onchain
 *      dynamic traits. It's not meant to be inherited from or otherwise used in
 *      production. It's recommended to leave it in place as you work through
 *      the tutorial, then rip out all Dockmaster related contracts and tests.
 */
contract Dockmaster is AbstractNFT {
    using LibString for string;
    using LibString for uint256;

    uint256 public currentId;

    event Hail(string message);

    error UnauthorizedMinter();

    constructor(string memory __name, string memory __symbol, address __owner) AbstractNFT(__name, __symbol) {
        _name = __name;
        _symbol = __symbol;
        _initializeOwner(__owner == address(0) ? msg.sender : __owner);
        emit Hail(string(abi.encodePacked("Hi Mom! I'm deploying my very own ", __name, " contract!")));
    }

    /**
     * @dev Returns the URI for a given token ID. It's not necessary to override
     *      this function, but this contract overrides it to demonstrate that
     *      it's possible to change the opinions of AbstractNFT, which doesn't
     *      throw in the event that a supplied token ID doesn't exist.
     *
     * @param tokenId The token ID to get the URI for
     *
     * @return The URI for the given token ID
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (tokenId > currentId) {
            // The exisintg TokenDoesNotExist error would be better, this is
            // just to demonstrate a revert with a custom message.
            revert("Token ID does not exist");
        }
        return _stringURI(tokenId);
    }

    /**
     * @dev Internal helper function to get the raw JSON metadata for a given
     *      token ID. If this function is not overridden, the default "Example
     *      NFT" metadata will be returned.
     *
     * @param tokenId The token ID to get URI for
     *
     * @return The raw JSON metadata for the given token ID
     */
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
                // Note that the image is a base64-encoded SVG
                json.property("image", Metadata.base64SvgDataURI(_image(tokenId))),
                _attributes(tokenId)
            )
        );
    }

    /**
     * @dev Helper function to get both the static and dynamic attributes for a
     *      given token ID. It's pulled out for readability and to avoid stack
     *      pressure issues.
     *
     * @param tokenId The token ID to get the static and dynamic attributes for
     */
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
     * @dev Helper function to get the static attributes for a given token ID.
     *
     * @param tokenId The token ID to get the static attributes for
     *
     * @return The static attributes for the given token ID
     */
    function _staticAttributes(uint256 tokenId) internal view virtual override returns (string[] memory) {
        return Solarray.strings(
            Metadata.attribute({traitType: "Slip Number", value: tokenId.toString(), displayType: DisplayType.Number}),
            Metadata.attribute({traitType: "Dock Side", value: tokenId % 2 == 0 ? "North" : "South"})
        );
    }

    /**
     * @dev Helper function to get the image for a given token ID.
     *
     * @param tokenId The token ID to get the image for
     *
     * @return The image for the given token ID
     */
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

    /**
     * @dev The function to call to bring new tokens into existence. This
     *      function must be overridden, or the contract will not compile. The
     *      compiler error message would be "Error (3656): Contract "Dockmaster"
     *      should be marked as abstract."
     *
     * @param to The address to mint the token to. If the null address is
     *           supplied, the token will be minted to the address that called
     *           this function.
     */
    function mint(address to) public {
        // Only the contract owner and addresses with the two leading zeros can
        // mint tokens.
        bool callerFirstByteIsNonZero = (uint256(uint160(msg.sender)) >> (160 - 8)) > 0;
        if (callerFirstByteIsNonZero && msg.sender != owner()) {
            revert UnauthorizedMinter();
        }

        // If the null address is supplied, mint to the caller.
        to = to == address(0) ? msg.sender : to;

        unchecked {
            _mint(to, ++currentId);
        }
    }

    /**
     * @dev Internal function that's used in Dynamic Traits to determine whether
     *      a given address is allowed to set or delete a trait for a given
     *      token ID. This function must be overridden, or the contract will not
     *      compile. The compiler error message would be "Error (3656): Contract
     *      "Dockmaster" should be marked as abstract."
     */
    function _isOwnerOrApproved(uint256 tokenId, address addr) internal view override returns (bool) {
        return ownerOf(tokenId) == addr || getApproved(tokenId) == addr || isApprovedForAll(ownerOf(tokenId), addr);
    }

    function hail(string memory message) public {
        emit Hail(message);
    }
}
