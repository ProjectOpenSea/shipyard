// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { Shipyard } from "shipyard/Shipyard.sol";

contract ShipYardTest is Test {
    Shipyard shipyard;

    function setUp() public {
        shipyard = new Shipyard();
    }

    function testAhoy() public {
        assertEq(bytes(shipyard.greet()), bytes("Ahoy"));
    }
}
