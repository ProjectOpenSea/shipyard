// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

interface DeleteTraitInterface {
    function deleteTrait(bytes32 traitKey, uint256 tokenId) external;
}

/**
 * @title DeleteTraitScript
 * @notice This script deletes a trait for a given traitKey and tokenId. Note
 *         That this is not permissible if the trait is required to have a
 *         value. Check the current tokenURI response for token 1 by running
 *         `cast call --rpc-url $GOERLI_RPC_URL
 *         <the_address_of_the_target_contract> "tokenURI(uint256)(string)" 1`.
 *         It should return the base64 encoded json for the NFT. Then run
 *         `forge script script/DeleteTrait.s.sol --tc DeleteTraitScript
 *         --sender <the_deployer_address> --fork-url $GOERLI_RPC_URL -vvvv` to
 *         simulate the tx. To run it for real, change it to `forge script
 *         script/DeleteTrait.s.sol --tc DeleteTraitScript --private-key
 *         $MY_ACTUAL_PK_BE_CAREFUL --fork-url $GOERLI_RPC_URL --broadcast`.
 */
contract DeleteTraitScript is Script {
    DeleteTraitInterface targetContract;

    function setUp() public {
        // Add the address of the target contract to the script here.
        targetContract = DeleteTraitInterface(address(0));
    }

    function run() public {
        // Call the function to delete the trait on token ID 1.
        vm.startBroadcast();

        targetContract.deleteTrait(bytes32("test.scriptTest"), 1);
    }
}
