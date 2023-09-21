// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";

import {ExampleNFT} from "shipyard-core/reference/ExampleNFT.sol";

import "forge-std/console.sol";

contract Deploy is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("MY_ACTUAL_PK_BE_CAREFUL");
        vm.startBroadcast(deployerPrivateKey);
        new ExampleNFT('Example', 'EXNFT');
        vm.stopBroadcast();
    }
}
