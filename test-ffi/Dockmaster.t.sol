// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Base64} from "solady/utils/Base64.sol";
import {Test} from "forge-std/Test.sol";
import {Dockmaster} from "src/Dockmaster.sol";
import {
    AllowedEditor,
    DisplayType,
    Editors,
    EditorsLib,
    FullTraitValue,
    TraitLabel
} from "shipyard-core/dynamic-traits/lib/TraitLabelLib.sol";

struct Attribute {
    string attrType;
    string value;
    string displayType;
}

contract DockmasterTest is Test {
    Dockmaster dockmaster;

    string TEMP_JSON_PATH_PREFIX = "./test-ffi/tmp/temp";
    string TEMP_JSON_PATH_FILE_TYPE = ".json";
    string PROCESS_JSON_PATH = "./test-ffi/scripts/process_json.js";

    function setUp() public {
        dockmaster = new Dockmaster('Dockmaster', 'DM', address(0));
        for (uint256 i; i < 10; i++) {
            vm.prank(address(0));
            dockmaster.mint(address(this));
        }
    }

    function testStringURI(uint256 tokenId) public {
        tokenId = bound(tokenId, 1, 10);

        // Create a file name to use throughtout the test. It will have a form
        // like ./test-ffi/tmp/temp-<gasleft>-<tokenId>.json. It will be
        // deleted at the end of the test.
        string memory fileName = _fileName(tokenId);

        // Populate the temp file with the json.
        _populateTempFileWithJson(tokenId, fileName);

        // Get the name, description, and image from the json.
        (string memory name, string memory description, string memory image) = _getNameDescriptionAndImage(fileName);

        // Check the name, description, and image against expectations.
        assertEq(name, _generateExpectedTokenName(tokenId), "The token name should be Slip #<tokenId>");
        assertEq(
            description,
            string(abi.encodePacked("Slip #", vm.toString(tokenId), ".")),
            "The description should be Slip #"
        );
        assertEq(image, _generateExpectedTokenImage(tokenId), "The image is incorrect.");

        // Set up the expectations for the two static traits.
        Attribute[] memory attributes = new Attribute[](2);

        attributes[0] = Attribute({attrType: "Slip #", value: vm.toString(tokenId), displayType: "number"});
        attributes[1] = Attribute({
            attrType: "Dock Side",
            value: tokenId % 2 == 0 ? "North" : "South",
            displayType: "noDisplayType"
        });

        // Check for the two static traits.
        _checkAttributesAgainstExpectations(tokenId, attributes, fileName);

        // Set the ship is in trait and check for it.
        dockmaster.setShipIsIn(tokenId, true);

        _populateTempFileWithJson(tokenId, fileName);

        // Get the name, description, and image from the json.
        (name, description, image) = _getNameDescriptionAndImage(fileName);

        // Check the name, description, and image against expectations.
        assertEq(name, _generateExpectedTokenName(tokenId), "The token name should be Dockmaster NFT #<tokenId>");
        assertEq(
            description,
            string(abi.encodePacked("Slip #", vm.toString(tokenId), ".")),
            "The description should be Slip #"
        );
        assertEq(image, _generateExpectedTokenImage(tokenId), "The image is incorrect.");

        // Set up the expectations for the two static traits.
        attributes = new Attribute[](3);

        attributes[0] = Attribute({attrType: "Slip #", value: vm.toString(tokenId), displayType: "number"});
        attributes[1] = Attribute({
            attrType: "Dock Side",
            value: tokenId % 2 == 0 ? "North" : "South",
            displayType: "noDisplayType"
        });
        attributes[2] = Attribute({attrType: "Ship Is In", value: "True", displayType: "string"});

        // Check for the two static traits.
        _checkAttributesAgainstExpectations(tokenId, attributes, fileName);
    }

    function testDynamicMetadataDirect(uint256 tokenId) public {
        tokenId = bound(tokenId, 1, 10);

        // Create and set a new trait label on the contract.

        // Build the trait label.
        string[] memory acceptableValues = new string[](2);
        acceptableValues[0] = "True";
        acceptableValues[1] = "False";

        AllowedEditor[] memory allowedEditorRoles = new AllowedEditor[](2);
        allowedEditorRoles[0] = AllowedEditor.Self;
        allowedEditorRoles[1] = AllowedEditor.TokenOwner;

        Editors editors = EditorsLib.aggregate(allowedEditorRoles);

        TraitLabel memory label = TraitLabel({
            fullTraitKey: "Your Second Ship Came In",
            traitLabel: "Your Second Ship Came In",
            acceptableValues: acceptableValues,
            fullTraitValues: new FullTraitValue[](0),
            displayType: DisplayType.String,
            editors: editors,
            required: false
        });

        // Check label editor auth (onlyOwner).
        vm.prank(address(0));
        vm.expectRevert(abi.encodeWithSignature("Unauthorized()"));
        dockmaster.setTraitLabel(bytes32("dockmaster.secondShipIsIn"), label);

        // Call the function to add the new label.
        dockmaster.setTraitLabel(bytes32("dockmaster.secondShipIsIn"), label);

        // Check editor auth (as defined by allowedEditorRoles).
        vm.prank(address(1));
        vm.expectRevert(abi.encodeWithSignature("InsufficientPrivilege()"));
        dockmaster.setTrait(bytes32("dockmaster.secondShipIsIn"), tokenId, "True");

        // Call the function to add the new trait. Caller is address(this),
        // which is permitted by `AllowedEditor.Self`.
        dockmaster.setTrait(bytes32("dockmaster.secondShipIsIn"), tokenId, "True");

        // Create a file name to use throughtout the test. It will have a form
        // like ./test-ffi/tmp/temp-<gasleft>-<tokenId>.json. It will be
        // deleted at the end of the test.
        string memory fileNameTrueState = _fileName(tokenId);

        // Populate the temp file with the json.
        _populateTempFileWithJson(tokenId, fileNameTrueState);

        // Check for the new trait.
        Attribute[] memory attributes = new Attribute[](4);

        attributes[0] = Attribute({attrType: "Slip #", value: vm.toString(tokenId), displayType: "number"});
        attributes[1] = Attribute({
            attrType: "Dock Side",
            value: tokenId % 2 == 0 ? "North" : "South",
            displayType: "noDisplayType"
        });
        attributes[2] = Attribute({attrType: "Ship Is In", value: "False", displayType: "string"});
        attributes[3] = Attribute({attrType: "Your Second Ship Came In", value: "True", displayType: "string"});

        // Check for the new trait in True state.
        _checkAttributesAgainstExpectations(tokenId, attributes, fileNameTrueState);

        // Call the function to add the new trait in False state.
        vm.prank(dockmaster.ownerOf(tokenId));
        dockmaster.setTrait(bytes32("dockmaster.secondShipIsIn"), tokenId, "False");

        // Create a file name to use throughtout the test. It will have a form
        // like ./test-ffi/tmp/temp-<gasleft>-<tokenId>.json. It will be
        // deleted at the end of the test.
        string memory fileNameFalseState = _fileName(tokenId);

        // Populate the temp file with the json.
        _populateTempFileWithJson(tokenId, fileNameFalseState);

        // Check for the new trait.
        attributes[3] = Attribute({attrType: "Your Second Ship Came In", value: "False", displayType: "string"});

        _checkAttributesAgainstExpectations(tokenId, attributes, fileNameFalseState);

        // Call the function to delete the trait.
        dockmaster.deleteTrait(bytes32("dockmaster.secondShipIsIn"), tokenId);

        // Create a file name to use throughtout the test. It will have a form
        // like ./test-ffi/tmp/temp-<gasleft>-<tokenId>.json. It will be
        // deleted at the end of the test.
        string memory fileNameDeletedState = _fileName(tokenId);

        // Populate the temp file with the json.
        _populateTempFileWithJson(tokenId, fileNameDeletedState);

        // This just checks that the two original traits are still there. It
        // might be worth writing an addition script to check the length of the
        // attributes array as a way of checking for the non-existence of the
        // deleted trait.
        attributes = new Attribute[](3);

        attributes[0] = Attribute({attrType: "Slip #", value: vm.toString(tokenId), displayType: "number"});
        attributes[1] = Attribute({
            attrType: "Dock Side",
            value: tokenId % 2 == 0 ? "North" : "South",
            displayType: "noDisplayType"
        });
        attributes[2] = Attribute({attrType: "Ship Is In", value: "False", displayType: "string"});

        // Check for the two static traits.
        _checkAttributesAgainstExpectations(tokenId, attributes, fileNameDeletedState);
    }

    ////////////////////////////////////////////////////////////////////////////
    //                         ffi Helpers                                    //
    ////////////////////////////////////////////////////////////////////////////

    function _getNameDescriptionAndImage(string memory file)
        internal
        returns (string memory name, string memory description, string memory image)
    {
        // Run the process_json.js script on the file to extract the values.
        // This will also check for json validity.
        string[] memory commandLineInputs = new string[](4);
        commandLineInputs[0] = "node";
        commandLineInputs[1] = PROCESS_JSON_PATH;
        // In ffi, the script is executed from the top-level directory, so
        // there has to be a way to specify the path to the file where the
        // json is written.
        commandLineInputs[2] = file;
        // Optional field. Default is to only get the top level values (name,
        // description, and image). This is present for the sake of
        // explicitness.
        commandLineInputs[3] = "--top-level";

        if (vm.exists(file)) {
            (name, description, image) = abi.decode(vm.ffi(commandLineInputs), (string, string, string));
        }

        image = string(Base64.decode(_cleanedSvg(image)));
    }

    function _getAttributeAtIndex(uint256 attributeIndex, string memory file)
        internal
        returns (string memory attrType, string memory value, string memory displayType)
    {
        // Run the process_json.js script on the file to extract the values.
        // This will also check for json validity.
        string[] memory commandLineInputs = new string[](5);
        commandLineInputs[0] = "node";
        commandLineInputs[1] = PROCESS_JSON_PATH;
        // In ffi, the script is executed from the top-level directory, so
        // there has to be a way to specify the path to the file where the
        // json is written.
        commandLineInputs[2] = file;
        // Optional. Default is to only get the top level values (name,
        // description, and image). This is present for the sake of
        // explicitness.
        commandLineInputs[3] = "--attribute";
        commandLineInputs[4] = vm.toString(attributeIndex);

        if (vm.exists(file)) {
            (attrType, value, displayType) = abi.decode(vm.ffi(commandLineInputs), (string, string, string));
        } else {
            revert("File does not exist.");
        }
    }

    function _populateTempFileWithJson(uint256 tokenId, string memory file) internal {
        // Get the raw URI response.
        string memory rawUri = dockmaster.tokenURI(tokenId);

        // Write the decoded json to a file.
        vm.writeFile(file, rawUri);
    }

    function _cleanedSvg(string memory uri) internal pure returns (string memory) {
        uint256 stringLength;

        // Get the length of the string from the abi encoded version.
        assembly {
            stringLength := mload(uri)
        }

        // Remove the "data:image/svg+xml;base64," prefix.
        return _substring(uri, 26, stringLength);
    }

    function _substring(string memory str, uint256 startIndex, uint256 endIndex) public pure returns (string memory) {
        bytes memory strBytes = bytes(str);

        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    function _fileName(uint256 tokenId) internal view returns (string memory) {
        // Create a new file for each token ID and for each call possible token
        // state. Using gasLeft() prevents collisions across tests imprefectly
        // but tolerably. The token ID is for reference.
        return string.concat(
            TEMP_JSON_PATH_PREFIX, "-", vm.toString(gasleft()), "-", vm.toString(tokenId), TEMP_JSON_PATH_FILE_TYPE
        );
    }

    function _cleanUp(string memory file) internal {
        if (vm.exists(file)) {
            vm.removeFile(file);
        }
        assertFalse(vm.exists(file));
    }

    ////////////////////////////////////////////////////////////////////////////
    //                        Assertion Helpers                               //
    ////////////////////////////////////////////////////////////////////////////

    function _generateExpectedTokenName(uint256 tokenId) internal pure returns (string memory) {
        return string(abi.encodePacked("Slip #", vm.toString(uint256(tokenId))));
    }

    function _generateExpectedTokenImage(uint256 tokenId) internal view returns (string memory image) {
        image = string(
            abi.encodePacked(
                // Some IDE syntax highlighting gets massively confused by this
                // string. It's fine, though.
                "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"500\" height=\"500\" ><rect x=\"0\" y=\"0\" width=\"500\" height=\"500\" fill=\"#add8e6\" /><rect x=\"100\" y=\"175\" width=\"300\" height=\"175\" fill=\"#a0522d\" /><rect x=\"120\" y=\"250\" width=\"260\" height=\"80\" fill=\"#add8e6\" />",
                dockmaster.getShipIsIn(tokenId)
                    ?
                    "<rect x=\"405\" y=\"125\" width=\"100\" height=\"175\" fill=\"#2f4f4f\" /><circle cx=\"480\" cy=\"275\" r=\"80\" fill=\"#2f4f4f\" /><rect x=\"405\" y=\"150\" width=\"100\" height=\"15\" fill=\"#800000\" />"
                    : "",
                "<rect x=\"0\" y=\"330\" width=\"500\" height=\"170\" fill=\"#00008b\" /><text x=\"50%\" y=\"225\" text-anchor=\"middle\" font-size=\"48\" >"
                "Slip #",
                vm.toString(tokenId),
                "</text></svg>"
            )
        );

        return image;
    }

    function _checkAttributesAgainstExpectations(uint256 tokenId, Attribute[] memory attributes, string memory file)
        internal
    {
        for (uint256 i; i < attributes.length; i++) {
            (string memory attrType, string memory value, string memory displayType) = _getAttributeAtIndex(i, file);

            assertEq(
                attrType, attributes[i].attrType, _generateError(tokenId, i, "attrType inconsistent with expected")
            );
            assertEq(value, attributes[i].value, _generateError(tokenId, i, "value inconsistent with expected"));
            assertEq(
                displayType,
                attributes[i].displayType,
                _generateError(tokenId, i, "displayType inconsistent with expected")
            );
        }

        // Clear out the file once it's served its purpose. If one of the checks
        // above fails, this will not be called and the file will be left behind
        // in the tmp directory for reference.
        _cleanUp(file);
    }

    function _generateError(uint256 tokenId, uint256 traitIndex, string memory message)
        internal
        pure
        returns (string memory)
    {
        return string(
            abi.encodePacked(
                "Error: ", message, " for token ", vm.toString(tokenId), " and trait index ", vm.toString(traitIndex)
            )
        );
    }
}
