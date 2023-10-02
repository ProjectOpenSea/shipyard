// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Base64} from "solady/utils/Base64.sol";
import {Test} from "forge-std/Test.sol";
import {Dockmaster} from "src/Dockmaster.sol";

contract ValidateDockmasterSvgTest is Test {
    Dockmaster dockmaster;

    string TEMP_JSON_PATH = "./test-ffi/tmp/temp.json";
    string PROCESS_JSON_PATH = "./test-ffi/scripts/process_json.js";

    string TEMP_SVG_DIR_PATH_AND_PREFIX = "./test-ffi/tmp/temp-";
    string TEMP_SVG_FILE_TYPE = ".svg";
    string VALIDATE_SVG_PATH = "./test-ffi/scripts/validate_svg.js";

    function setUp() public {
        dockmaster = new Dockmaster('Dockmaster', 'DM', address(0));
        for (uint256 i; i < 10; i++) {
            vm.prank(address(0));
            dockmaster.mint(address(this));
        }
    }

    function testValidateDockMasterSvg(uint256 tokenId) public {
        tokenId = bound(tokenId, 1, 10);

        // Populate the json file with the json from the tokenURI function.
        _populateTempFileWithJson(tokenId);

        // Get the output of the NFT's tokenURI function and grab the image from
        // it, then decode it.
        string memory image = _getImage();

        // Write the svg to a file.
        vm.writeFile(string(abi.encodePacked(TEMP_SVG_DIR_PATH_AND_PREFIX, "dockmaster", TEMP_SVG_FILE_TYPE)), image);

        _validateSvg("dockmaster");
    }

    ////////////////////////////////////////////////////////////////////////////
    //                          Helpers                                       //
    ////////////////////////////////////////////////////////////////////////////

    function _validateSvg(string memory file) internal {
        string memory fileName = string(abi.encodePacked(TEMP_SVG_DIR_PATH_AND_PREFIX, file, TEMP_SVG_FILE_TYPE));

        // Run the validate_svg.js script on the file to validate the svg.
        string[] memory commandLineInputs = new string[](3);
        commandLineInputs[0] = "node";
        commandLineInputs[1] = VALIDATE_SVG_PATH;
        commandLineInputs[2] = fileName;

        (bool isValid, string memory svg) = abi.decode(vm.ffi(commandLineInputs), (bool, string));

        assertEq(isValid, true, string(abi.encodePacked("The svg should be valid. Invalid svg: ", svg)));

        // Clear out the files once theyve served their purpose. If the check
        // above fails, this will not be called and the files will be left
        // behind in the tmp directory for reference.
        _cleanUp(fileName);
        _cleanUp(TEMP_JSON_PATH);
    }

    function _populateTempFileWithJson(uint256 tokenId) internal {
        // Get the raw URI response.
        string memory rawUri = dockmaster.tokenURI(tokenId);

        // Write the raw URI to a file.
        vm.writeFile(TEMP_JSON_PATH, rawUri);
    }

    function _getImage() internal returns (string memory) {
        // Run the process_json.js script on the file to extract the values.
        // This will also check for json validity.
        string[] memory commandLineInputs = new string[](4);
        commandLineInputs[0] = "node";
        commandLineInputs[1] = PROCESS_JSON_PATH;
        // In ffi, the script is executed from the top-level directory, so
        // there has to be a way to specify the path to the file where the
        // json is written.
        commandLineInputs[2] = TEMP_JSON_PATH;
        // Optional field. Default is to only get the top level values (name,
        // description, and image). This is present for the sake of
        // explicitness.
        commandLineInputs[3] = "--top-level";

        // Get the raw image.
        (,, string memory image) = abi.decode(vm.ffi(commandLineInputs), (string, string, string));

        // Return the cleaned and decoded image.
        return string(Base64.decode(_cleanedSvg(image)));
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

    function _cleanUp(string memory file) internal {
        if (vm.exists(file)) {
            vm.removeFile(file);
        }
        assertFalse(vm.exists(file));
    }
}
