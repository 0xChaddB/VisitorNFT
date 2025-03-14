// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";
import {VisitorNFT} from "../src/VisitorNFT.sol";

contract DeployVisitorNFT is Script {
    // Configuration parameters
    string private constant BASE_URI = "https://example.com/metadata/";
    
    function run() external returns (VisitorNFT) {
        // Load the deployer's private key for authorized transactions
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address relayerAddress = vm.envAddress("RELAYER_ADDRESS");
        
        // Start broadcasting transactions to the network
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy the VisitorNFT contract
        VisitorNFT nft = new VisitorNFT(BASE_URI, relayerAddress);
        
        // End broadcasting
        vm.stopBroadcast();
        
        // Log deployment information
        console.log("VisitorNFT deployed at:", address(nft));
        console.log("Base URI set to:", BASE_URI);
        console.log("Relayer address set to:", relayerAddress);
        
        return nft;
    }
}