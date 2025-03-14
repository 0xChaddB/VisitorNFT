// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {VisitorNFT} from "../src/VisitorNFT.sol";

contract DeployVisitorNFT is Script {
    // Configuration parameters
    string private constant BASE_URI = "RANDOM";
    address relayer = vm.envAddress("RELAYER_ADDRESS");
    
    function run() external returns (VisitorNFT) {
        vm.startBroadcast();

        VisitorNFT nft = new VisitorNFT(BASE_URI, relayer);
        
        vm.stopBroadcast();
        
        // Log deployment information
        console.log("VisitorNFT deployed at:", address(nft));
        console.log("Base URI set to:", BASE_URI);
        console.log("Relayer address set to:", relayerAddress);
        
        return nft;
    }
}