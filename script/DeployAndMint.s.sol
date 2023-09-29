// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
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
        // The deploy and the mint need to happen within the same
        // `startBroadcast`/`stopBroadcast` block. Otherwise, the script will
        // fail because Foundry will not recognize that the sender is the owner
        // of the token contract. See
        // https://book.getfoundry.sh/cheatcodes/start-broadcast for more info.
        vm.startBroadcast();

        // Create a new Dockmaster contract.
        Dockmaster targetContract = new Dockmaster("Dockmaster NFT", "DM");

        // Mint a token to the caller.
        targetContract.mint(address(0));

        vm.stopBroadcast();

        // Log some links to Etherscan and OpenSea.
        string memory openSeaPrefix =
            block.chainid == 5 ? "https://testnets.opensea.io/assets/goerli/" : "https://opensea.io/assets/ethereum/";

        string memory etherscanPrefix =
            block.chainid == 5 ? "https://goerli.etherscan.io/address/" : "https://etherscan.io/address/";

        // The `"\x1b[1m%s\x1b[0m"` causes the string to be printed in bold.
        console.log("\x1b[1m%s\x1b[0m", "Deployed an NFT contract at:");
        console.log(string(abi.encodePacked(etherscanPrefix, vm.toString(address(targetContract)))));
        console.log("");
        console.log("\x1b[1m%s\x1b[0m", "Minted a token to the caller:");
        console.log(string(abi.encodePacked(openSeaPrefix, vm.toString(address(targetContract)), "/1")));
        console.log("");
        console.log(
            "\x1b[1m%s\x1b[0m",
            "Please note that it will take perhaps 15 seconds "
            "for the transaction to be mined and a few additional seconds for "
            "OpenSea to pick up the transaction and reflect the existence of the NFT."
        );
    }
}
