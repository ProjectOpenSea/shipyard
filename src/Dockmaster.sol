// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {LibString} from "solady/utils/LibString.sol";
import {Solarray} from "solarray/Solarray.sol";
import {
    AllowedEditor,
    DisplayType,
    Editors,
    EditorsLib,
    FullTraitValue,
    TraitLabel
} from "shipyard-core/dynamic-traits/lib/TraitLabelLib.sol";
import {json} from "shipyard-core/onchain/json.sol";
import {svg} from "shipyard-core/onchain/svg.sol";
import {Metadata, DisplayType} from "shipyard-core/onchain/Metadata.sol";
import {AbstractNFT} from "shipyard-core/reference/AbstractNFT.sol";

/**
 * @title Dockmaster
 * @dev This is an example NFT contract that demonstrates how to use the
 *      AbstractNFT contract to create an NFT with onchain metadata and onchain
 *      dynamic traits. It's not meant to be inherited from or otherwise used in
 *      production. It's recommended to leave it in place as you work through
 *      the tutorial, then rip out all Dockmaster related contracts and tests.
 */
contract Dockmaster is AbstractNFT {
    using LibString for uint256;

    // Tracks the highest token ID minted so far.
    uint256 public currentId;

    // An error specific to Dockmaster.
    error UnauthorizedMinter();

    // The name and symbol arguments are required since the contract inherits
    // from AbstractNFT. The owner argument is optional, but it's necessary when
    // deploying via the keyless create2 factory.
    constructor(string memory __name, string memory __symbol, address __owner) AbstractNFT(__name, __symbol) {
        _name = __name;
        _symbol = __symbol;

        // Override the default owner initialization.
        _initializeOwner(__owner == address(0) ? msg.sender : __owner);

        // Initialize the shipIsIn trait label.
        string[] memory acceptableValues = new string[](2);
        acceptableValues[0] = "True";
        acceptableValues[1] = "False";

        AllowedEditor[] memory allowedEditorRoles = new AllowedEditor[](1);
        allowedEditorRoles[0] = AllowedEditor.TokenOwner;

        _setTraitLabel(
            bytes32("dockmaster.shipIsIn"),
            TraitLabel({
                fullTraitKey: "",
                traitLabel: "Ship Is In",
                acceptableValues: acceptableValues,
                fullTraitValues: new FullTraitValue[](0),
                displayType: DisplayType.String,
                editors: EditorsLib.aggregate(allowedEditorRoles),
                required: false
            })
        );
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
        string[] memory staticTraits = _staticAttributes(tokenId);
        string[] memory dynamicTraits = _dynamicAttributes(tokenId);
        string[] memory combined = new string[](staticTraits.length + dynamicTraits.length);
        for (uint256 i = 0; i < staticTraits.length; i++) {
            combined[i] = staticTraits[i];
        }
        for (uint256 i = 0; i < dynamicTraits.length; i++) {
            combined[staticTraits.length + i] = dynamicTraits[i];
        }

        return json.objectOf(
            Solarray.strings(
                json.property("name", string.concat("Slip #", tokenId.toString())),
                json.property("description", string.concat("Slip #", tokenId.toString(), ".")),
                // Note that the image is a base64-encoded SVG
                json.property("image", Metadata.base64SvgDataURI(_image(tokenId))),
                json.rawProperty("attributes", json.arrayOf(combined))
            )
        );
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
            Metadata.attribute({traitType: "Slip #", value: tokenId.toString(), displayType: DisplayType.Number}),
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
    function _image(uint256 tokenId) internal view override returns (string memory) {
        // Declare a variable for "500" to get below the contract size limit.
        string memory fiveHundred = "500";

        return svg.top({
            props: string.concat(svg.prop("width", fiveHundred), svg.prop("height", fiveHundred)),
            children: string.concat(
                // Sky
                _generateRect("0", "0", fiveHundred, fiveHundred, "#add8e6"),
                // Dock
                _generateRect("100", "175", "300", "175", "#a0522d"),
                // Under the booooaaarrrddwalk
                _generateRect("120", "250", "260", "80", "#add8e6"),
                // Ship, if it's in.
                getShipIsIn(tokenId) ? _generateShip() : "",
                // Water
                _generateRect("0", "330", fiveHundred, "170", "#00008b"),
                // Slip number
                svg.text({
                    props: string.concat(
                        svg.prop("x", "50%"),
                        svg.prop("y", "225"),
                        svg.prop("text-anchor", "middle"),
                        svg.prop("font-size", "48")
                        ),
                    children: string.concat("Slip #", tokenId.toString())
                })
                )
        });
    }

    function _generateShip() internal pure returns (string memory) {
        return string.concat(
            // Hull
            _generateRect("405", "125", "100", "175", "#2f4f4f"),
            // Chine
            svg.circle({
                props: string.concat(
                    svg.prop("cx", "480"), svg.prop("cy", "275"), svg.prop("r", "80"), svg.prop("fill", "#2f4f4f")
                    )
            }),
            // Accent stripe
            _generateRect("405", "150", "100", "15", "#800000")
        );
    }

    /**
     * @dev Helper function to generate a rectangle with less boilerplate.
     */
    function _generateRect(
        string memory x,
        string memory y,
        string memory width,
        string memory height,
        string memory fill
    ) internal pure returns (string memory) {
        return svg.rect({
            props: string.concat(
                svg.prop("x", x),
                svg.prop("y", y),
                svg.prop("width", width),
                svg.prop("height", height),
                svg.prop("fill", fill)
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
        if (((uint256(uint160(msg.sender)) >> (160 - 8)) > 0) && msg.sender != owner()) {
            revert UnauthorizedMinter();
        }

        // The "unchecked" keyword saves gas, and since it's unlikely that
        // anyone will mint that many tokens, it's safe to use here.
        unchecked {
            // Increment the currentId and mint the token.
            _mint(to, ++currentId);
        }

        // Initialize the shipIsIn trait for the new token to false.
        setShipIsIn(currentId, false);
    }

    /**
     * @dev Internal function that's used in Dynamic Traits to determine whether
     *      a given address is allowed to set or delete a trait for a given
     *      token ID. This function must be overridden, or the contract will not
     *      compile. The compiler error message would be "Error (3656): Contract
     *      "Dockmaster" should be marked as abstract."
     */
    function _isOwnerOrApproved(uint256 tokenId, address addr) internal view override returns (bool) {
        return ownerOf(tokenId) == addr;
    }

    /**
     * @dev Wrapper around `_setTrait` that sets a specific trait (shipIsIn).
     */
    function setShipIsIn(uint256 tokenId, bool _shipIsIn) public {
        _setTrait(bytes32("dockmaster.shipIsIn"), tokenId, _shipIsIn ? bytes32("True") : bytes32("False"));
    }

    /**
     * @dev Getter function for the shipIsIn status.
     *
     * @param tokenId The token ID to get the shipIsIn status for
     *
     * @return A boolean for whether the ship is in or not
     */
    function getShipIsIn(uint256 tokenId) public view returns (bool) {
        // Access the trait directly instead of using `getTraitValue` to avoid
        // the revert if the trait has been deleted.
        return _traits[tokenId][bytes32("dockmaster.shipIsIn")] == bytes32("True");
    }
}
