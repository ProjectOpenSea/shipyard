// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

interface SetTraitInterface {
    function setTrait(bytes32 traitKey, uint256 tokenId, bytes32 trait) external;
}

/**
 * @title SetTraitScript
 * @notice This script sets a trait on a Dynamic Traits contract. Check the
 *         current tokenURI response for token 1 by running `cast call --rpc-url
 *         $GOERLI_RPC_URL <the_address_of_the_target_contract>
 *         "tokenURI(uint256)(string)" 1`. It should return the base64 encoded
 *         json for the NFT. Then run `forge script script/SetTrait.s.sol --tc
 *         SetTraitScript --sender <the_deployer_address> --fork-url
 *         $GOERLI_RPC_URL -vvvv` to simulate the tx.
 */
contract SetTraitScript is Script {
    SetTraitInterface targetContract;

    function setUp() public {
        // Replace the address of the target NFT contract here.
        targetContract = SetTraitInterface(address(0));
    }

    function run() public {
        // Call the function to set the trait on token ID 1.
        vm.broadcast();
        targetContract.setTrait(bytes32("test.scriptTest"), 1, "First Value");
    }
}
