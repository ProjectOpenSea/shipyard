// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

interface MintInterface {
    function mint(address to) external;
}

/**
 * @title MintScript
 * @notice This script mints a token. Simulate running it by entering `forge
 *         script script/Mint.s.sol --tc MintScript --sender
 *         <the_caller_address> --fork-url $GOERLI_RPC_URL -vvvv` in the
 *         terminal. To run it for real, change it to `forge script
 *         script/Mint.s.sol --tc MintScript --private-key
 *         $MY_ACTUAL_PK_BE_CAREFUL --fork-url $GOERLI_RPC_URL --broadcast`.
 *
 */
contract MintScript is Script {
    MintInterface targetContract;

    function setUp() public {
        // Replace the address of the target NFT contract here.
        targetContract = MintInterface(address(0));
    }

    function run() public {
        // Call the function to mint a token. Note that the mint function on the
        // Dockmaster contract can only be called by an address with two leading
        // zeros in its address.
        vm.broadcast();

        // Replace the address below with the address that should recieve the
        // token.
        targetContract.mint(address(0));
    }
}
