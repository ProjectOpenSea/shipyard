// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Dockmaster.sol";
import "../src/DockmasterInterface.sol";

/**
 * @title DockmasterTest
 * @dev Test contract for the Dockmaster contract. This test suite is not meant
 *      to be considered exhaustive, just demonstrative. It primarily targets
 *      the places where Dockmaster behaves differently than AbstractNFT, which
 *      is tested in shipyard-core. This test suite is supplemented by the
 *      Dockmaster.t.sol test and the ValidateDockmasterSvg.t.sol test in
 *      the test-ffi directory.
 */
contract DockmasterTest is Test {
    DockmasterInterface public dockmaster;

    error UnauthorizedMinter();

    function setUp() public {
        // Deploy a new Dockmaster contract for the test and get its address.
        Dockmaster dockmasterContract = new Dockmaster("Dockmaster NFT", "DM", address(0));
        address dockmasterAddress = address(dockmasterContract);
        // Set the dockmaster variable to an instance of the Dockmaster
        // interface.
        dockmaster = DockmasterInterface(dockmasterAddress);
    }

    function testName() public {
        assertEq(dockmaster.name(), "Dockmaster NFT");
    }

    function testSymbol() public {
        assertEq(dockmaster.symbol(), "DM");
    }

    function testTokenURI() public {
        // TODO: Fix in shipyard-core.
        // Verify that Dockmaster's tokenURI function overrides AbstractNFT's
        // tokenURI function and therefore reverts when the token ID does not
        // exist.
        // vm.expectRevert("Token ID does not exist");
        // dockmaster.tokenURI(type(uint128).max);

        // Prank an address with two leading zeros. See
        // https://book.getfoundry.sh/cheatcodes/prank for more info on
        // pranking.
        vm.prank(address(0));
        dockmaster.mint(address(this));

        // Check that the tokenURI function does not revert when the token ID
        // exists.
        uint256 tokenId = dockmaster.currentId() - 1;
        dockmaster.tokenURI(tokenId);
    }

    function testMint() public {
        // Passes on the strength of leading zeros.
        vm.prank(address(uint160(address(this)) >> (160 - 8)));
        dockmaster.mint(address(this));

        assertEq(dockmaster.ownerOf(1), address(this), "Owner of token 1 is not this contract.");
        assertEq(dockmaster.currentId(), 1, "Current ID is not 1.");

        // Passes on the strength of being the owner.
        dockmaster.mint(dockmaster.owner());

        assertEq(dockmaster.ownerOf(2), address(this), "Owner of token 2 is not this contract.");
        assertEq(dockmaster.currentId(), 2, "Current ID is not 2.");

        // Fails because the sender is not the owner and does not have two
        // leading zeros.
        vm.expectRevert(abi.encodeWithSignature("UnauthorizedMinter()"));
        vm.prank(address(uint160(address(this)) >> 1));
        dockmaster.mint(address(this));

        assertEq(dockmaster.currentId(), 2, "Current ID is not 2.");
    }
}
