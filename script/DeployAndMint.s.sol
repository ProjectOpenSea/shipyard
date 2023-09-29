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
    // Define a mapping from chainID to its respective URL
    mapping(uint256 => string) chainToBlockExplorer;
    mapping(uint256 => string) chainToOpenSea;

    function setUp() public {
        // Populate the chainToBlockExplorer and chainToOpenSea mappings.
        _setPrefixValues();
    }

    function run() public {
        // The deploy and the mint need to happen within the same
        // `startBroadcast`/`stopBroadcast` block. Otherwise, the script will
        // fail because Foundry will not recognize that the sender is the owner
        // of the token contract. See
        // https://book.getfoundry.sh/cheatcodes/start-broadcast for more info.
        vm.startBroadcast();

        // Create a new Dockmaster contract.
        Dockmaster targetContract = new Dockmaster("Dockmaster NFT", "DM", address(0));

        // Mint a token to the caller.
        targetContract.mint(address(0));

        vm.stopBroadcast();

        // The `"\x1b[1m%s\x1b[0m"` causes the string to be printed in bold.
        string memory boldString = "\x1b[1m%s\x1b[0m";
        string memory deployHypeString =
            _chainIsSupportedByABlockExplorer() ? "Deployed an NFT contract at:" : "Deployed an NFT contract!";
        string memory mintHypeString =
            _chainIsSupportedByOpenSea() ? "Minted a token to the caller:" : "Minted a token to the caller!";

        console.log(boldString, deployHypeString);
        console.log(boldString, _getBlockExplorerLog(address(targetContract)));
        console.log("");
        console.log(boldString, mintHypeString);
        console.log(boldString, _getOpenSeaLog(address(targetContract)));
        console.log("");
        console.log(
            boldString,
            "Please note that it will take perhaps 15 seconds "
            "for the transaction to be mined and a few additional seconds for "
            "OpenSea to pick up the transaction and reflect the existence of the NFT."
        );
    }

    function _getBlockExplorerLog(address targetContract) internal view returns (string memory) {
        // Only return a log if the chain is supported.
        string memory blockExplorerString = string(
            abi.encodePacked(
                "View the contract on a block explorer: ",
                chainToBlockExplorer[block.chainid],
                vm.toString(targetContract)
            )
        );

        return _chainIsSupportedByABlockExplorer() ? blockExplorerString : "";
    }

    function _getOpenSeaLog(address targetContract) internal view returns (string memory) {
        // Only return a log if the chain is supported.
        string memory openSeaString = string(
            abi.encodePacked(
                "View the token on OpenSea: ", chainToOpenSea[block.chainid], vm.toString(targetContract), "/1"
            )
        );

        return _chainIsSupportedByOpenSea() ? openSeaString : "";
    }

    function _chainIsSupportedByABlockExplorer() internal view returns (bool) {
        return keccak256(bytes(chainToBlockExplorer[block.chainid])) != keccak256(bytes(""));
    }

    function _chainIsSupportedByOpenSea() internal view returns (bool) {
        return keccak256(bytes(chainToOpenSea[block.chainid])) != keccak256(bytes(""));
    }

    function _setPrefixValues() internal {
        chainToBlockExplorer[1] = "https://etherscan.io/address/";
        chainToBlockExplorer[5] = "https://goerli.etherscan.io/address/";
        chainToBlockExplorer[11155111] = "https://sepolia.etherscan.io/address/";
        chainToBlockExplorer[137] = "https://polygonscan.com/address/";
        chainToBlockExplorer[80001] = "https://mumbai.polygonscan.com/address/";
        chainToBlockExplorer[43114] = "https://snowtrace.io/address/";
        chainToBlockExplorer[43113] = "https://testnet.snowtrace.io/address/";
        chainToBlockExplorer[100] = "https://gnosisscan.io/address/";
        chainToBlockExplorer[10200] = "https://gnosis-chiado.blockscout.com/address/";
        chainToBlockExplorer[42161] = "https://arbiscan.io/address/";
        chainToBlockExplorer[421613] = "https://goerli.arbiscan.io/address/";
        chainToBlockExplorer[42170] = "https://nova.arbiscan.io/address/";
        chainToBlockExplorer[10] = "https://optimistic.etherscan.io/address/";
        chainToBlockExplorer[420] = "https://goerli-optimism.etherscan.io/address/";
        chainToBlockExplorer[8453] = "https://basescan.org/address/";
        chainToBlockExplorer[84531] = "https://goerli.basescan.org/address";
        chainToBlockExplorer[7777777] = "https://explorer.zora.energy/address/";
        chainToBlockExplorer[999] = "https://testnet.explorer.zora.energy/address/";

        chainToOpenSea[1] = "https://opensea.io/assets/ethereum/";
        chainToOpenSea[5] = "https://testnets.opensea.io/assets/goerli/";
        chainToOpenSea[11155111] = "https://testnets.opensea.io/assets/sepolia/";
        chainToOpenSea[137] = "https://opensea.io/assets/matic/";
        chainToOpenSea[80001] = "https://testnets.opensea.io/assets/mumbai/";
        chainToOpenSea[43114] = "https://opensea.io/assets/avalanche/";
        chainToOpenSea[43113] = "https://testnets.opensea.io/assets/fuji/";
        chainToOpenSea[100] = "https://opensea.io/assets/gnosis/";
        chainToOpenSea[10200] = "https://testnets.opensea.io/assets/gnosis-chiado/";
        chainToOpenSea[42161] = "https://opensea.io/assets/arbitrum/";
        chainToOpenSea[421613] = "https://testnets.opensea.io/assets/arbitrum-goerli/";
        chainToOpenSea[42170] = "https://opensea.io/assets/arbitrum-nova/";
        chainToOpenSea[10] = "https://opensea.io/assets/optimism/";
        chainToOpenSea[420] = "https://testnets.opensea.io/assets/optimism-goerli/";
        chainToOpenSea[8453] = "https://opensea.io/assets/base/";
        chainToOpenSea[84531] = "https://testnets.opensea.io/assets/base-goerli/";
        chainToOpenSea[7777777] = "https://opensea.io/assets/zora/";
        chainToOpenSea[999] = "https://testnets.opensea.io/assets/zora-testnet/";
    }
}
