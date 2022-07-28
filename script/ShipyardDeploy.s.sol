// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import { Shipyard } from "shipyard/Shipyard.sol";

contract ShipyardDeployScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
        Shipyard shipyard = new Shipyard();
    }
}
