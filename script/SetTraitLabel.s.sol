// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {
    AllowedEditor,
    DisplayType,
    Editors,
    FullTraitValue,
    TraitLabel,
    EditorsLib
} from "shipyard-core/dynamic-traits/lib/TraitLabelLib.sol";

interface SetTraitLabelInterface {
    function setTraitLabel(bytes32 traitKey, TraitLabel memory _traitLabel) external;
}

/**
 * @title SetTraitLabelScript
 * @notice This script sets a trait label on a DynamicTraits contract. Simulate
 *         running it by entering `forge script script/SetTraitLabel.s.sol --tc
 *         SetTraitLabelScript --sender <the_deployer_address> --fork-url
 *         $GOERLI_RPC_URL -vvvv` in your terminal. To run it for real,
 *         change it to `forge script script/SetTraitLabel.s.sol --tc
 *         SetTraitLabelScript --private-key $MY_ACTUAL_PK_BE_CAREFUL --fork-url
 *         $GOERLI_RPC_URL --broadcast`.
 */
contract SetTraitLabelScript is Script {
    SetTraitLabelInterface targetContract;

    function setUp() public {
        // Replace the address of the target contract here.
        targetContract = SetTraitLabelInterface(address(0));
    }

    function run() public {
        // Build the trait label.
        string[] memory acceptableValues = new string[](2);
        acceptableValues[0] = "First Value";
        acceptableValues[1] = "Second Value";

        AllowedEditor[] memory allowedEditorRoles = new AllowedEditor[](2);
        allowedEditorRoles[0] = AllowedEditor.Self;
        allowedEditorRoles[1] = AllowedEditor.TokenOwner;

        Editors editors = EditorsLib.aggregate(allowedEditorRoles);

        TraitLabel memory label = TraitLabel({
            fullTraitKey: "Script test trait",
            traitLabel: "Script test trait",
            acceptableValues: acceptableValues,
            fullTraitValues: new FullTraitValue[](0),
            displayType: DisplayType.String,
            editors: editors,
            required: false
        });

        // Call the function to add the new label.
        vm.broadcast();
        targetContract.setTraitLabel(bytes32("test.scriptTest"), label);
    }
}
