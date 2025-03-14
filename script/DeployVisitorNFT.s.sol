// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {VisitorNFT} from "../src/VisitorNFT.sol";

contract DeployVisitorNFT is Script {
    function run() external returns (VisitorNFT) {

        string memory baseURI = "RANDOM";
        address relayer = vm.envAddress("RELAYER_ADDRESS");
        
        vm.startBroadcast();
        
        VisitorNFT nft = new VisitorNFT(baseURI, relayer);
        
        vm.stopBroadcast();
        
        // Log deployment information
        console.log("VisitorNFT deployed at:", address(nft));
        console.log("Base URI set to:", baseURI);
        console.log("Relayer address set to:", relayer);
        
        return nft;
    }
}