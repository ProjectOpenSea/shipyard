// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract ForkTest is Test {
    /**
     * @dev check that "fork" profile is active
     */
    function setUp() public virtual {
        string memory profile = vm.envString("FOUNDRY_PROFILE");
        if (keccak256(bytes(profile)) != keccak256("fork")) {
            revert(
                'The "fork" Foundry Profile has not been specified. Please run with FOUNDRY_PROFILE=fork and specify a --fork-url to mainnet.'
            );
        }
    }
}
