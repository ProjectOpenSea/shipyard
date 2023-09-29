// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Dockmaster.sol";

/**
 * @title DeployScript
 * @notice This script deploys a token contract. Simulate running it by entering
 *         `forge script script/Deploy.s.sol --sender <the_caller_address>
 *         --fork-url $GOERLI_RPC_URL -vvvv` in the terminal. To run it for
 *         real, change it to `forge script script/Deploy.s.sol --private-key
 *         $MY_ACTUAL_PK_BE_CAREFUL --fork-url $GOERLI_RPC_URL --broadcast`.
 *
 */
contract DeployScript is Script {
    function run() public {
        vm.broadcast();
        new Dockmaster("Dockmaster NFT", "DM", address(0));
    }
}
