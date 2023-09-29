// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Dockmaster.sol";

interface ImmutableCreate2Factory {
    function hasBeenDeployed(address deploymentAddress) external view returns (bool);

    function findCreate2Address(bytes32 salt, bytes calldata initializationCode)
        external
        view
        returns (address deploymentAddress);

    function safeCreate2(bytes32 salt, bytes calldata initializationCode)
        external
        payable
        returns (address deploymentAddress);
}

/**
 * @title CrossChainDeployScript
 * @notice This script deploys a contract to the same address regardless of
 *         which chain it's run on. Simulate running it by entering `forge
 *         script script/CrossChainDeploy.s.sol --tc CrossChainDeployScript
 *         --sender <the_caller_address> --fork-url $GOERLI_RPC_URL -vvvv` in
 *         the terminal. To run it for real, change it to `forge script
 *         script/CrossChainDeploy.s.sol --tc CrossChainDeployScript
 *         --private-key $MY_ACTUAL_PK_BE_CAREFUL --fork-url $GOERLI_RPC_URL
 *         --broadcast`. Note that it's probably a bad idea to deploy an NFT
 *         contract to multiple chains, but this script makes more sense if it
 *         targets an actual contract, and Dockmaster is what's available, so
 *         ¯\_(ツ)_/¯.
 *
 */
contract CrossChainDeployScript is Script {
    // Define a mapping from chainID to its respective URL
    mapping(uint256 => string) chainToBlockExplorer;

    // Set up the immutable create2 factory and conduit controller addresses.
    ImmutableCreate2Factory private constant IMMUTABLE_CREATE2_FACTORY =
        ImmutableCreate2Factory(0x0000000000FFe8B47B3e2130213B802212439497);

    // Set up the default salt. To deploy with a specific salt, replace it here
    // or pass it in as an argument to the `deploy` function below.
    bytes32 private constant DEFAULT_SALT = bytes32(uint256(0x1));

    function setUp() public {
        // Populate the chainToBlockExplorer mappings.
        _setPrefixValues();
    }

    function run() public {
        vm.startBroadcast();

        // Create a new Dockmaster contract.
        deploy(bytes.concat(type(Dockmaster).creationCode, abi.encode("Dockmaster", "DM", msg.sender)));

        vm.stopBroadcast();
    }

    function deploy(bytes memory initCode) internal returns (address) {
        return deploy(DEFAULT_SALT, initCode);
    }

    function deploy(bytes32 salt, bytes memory initCode) internal returns (address) {
        bytes32 initCodeHash = keccak256(initCode);
        address deploymentAddress = address(
            uint160(
                uint256(keccak256(abi.encodePacked(hex"ff", address(IMMUTABLE_CREATE2_FACTORY), salt, initCodeHash)))
            )
        );
        bool deploying;
        if (!IMMUTABLE_CREATE2_FACTORY.hasBeenDeployed(deploymentAddress)) {
            deploymentAddress = IMMUTABLE_CREATE2_FACTORY.safeCreate2(salt, initCode);
            deploying = true;
        }

        if (!deploying) {
            console.log(
                pad("Found", 10),
                pad(LibString.toHexString(deploymentAddress), 43),
                LibString.toHexString(uint256(initCodeHash))
            );
        } else {
            // The `"\x1b[1m%s\x1b[0m"` causes the string to be printed in bold.
            string memory boldString = "\x1b[1m%s\x1b[0m";
            string memory deployHypeString =
                _chainIsSupportedByABlockExplorer() ? "Deployed an NFT contract at:" : "Deployed an NFT contract!";

            console.log(boldString, deployHypeString);
            console.log(boldString, _getBlockExplorerLog(deploymentAddress));
            console.log("");
            console.log(boldString, "Initialization code hash:", LibString.toHexString(uint256(initCodeHash)));
        }

        return deploymentAddress;
    }

    function pad(string memory name, uint256 n) internal pure returns (string memory) {
        string memory padded = name;
        while (bytes(padded).length < n) {
            padded = string.concat(padded, " ");
        }
        return padded;
    }

    ////////////////////////////////////////////////////////////////////////////
    //                           Log Helpers                                  //
    ////////////////////////////////////////////////////////////////////////////

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

    function _chainIsSupportedByABlockExplorer() internal view returns (bool) {
        return keccak256(bytes(chainToBlockExplorer[block.chainid])) != keccak256(bytes(""));
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
    }
}
