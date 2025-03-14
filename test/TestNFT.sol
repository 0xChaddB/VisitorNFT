// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {VisitorNFT, ERC721, Ownable} from "../src/VisitorNFT.sol";
import {IERC721Errors} from "@openzeppelin/interfaces/draft-IERC6093.sol";


contract VisitorNFTTest is Test {
    VisitorNFT nft;
    address owner = makeAddr("owner");
    address relayer = makeAddr("relayer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");

    string constant BASE_URI = "https://example.com/metadata/";
    string constant METADATA_URI = "ipfs://QmTestMetadata123";

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    function setUp() public {
        // Déployer le contrat avec owner comme déployeur
        vm.prank(owner);
        nft = new VisitorNFT(BASE_URI, relayer);
    }


    function test_Deployment() public {
        assertEq(nft.owner(), owner, "Owner should be set correctly");
        assertEq(nft.getRelayer(), relayer, "Relayer should be set correctly");
        assertEq(nft.totalMinted(), 0, "Total minted should start at 0");
    }

    function test_MintByRelayer() public {
        vm.prank(relayer);
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), user1, 1);
        nft.entryMint(user1, METADATA_URI);

        assertEq(nft.totalMinted(), 1, "Total minted should increase");
        assertEq(nft.balanceOf(user1), 1, "User1 should own 1 NFT");
        assertEq(nft.ownerOf(1), user1, "User1 should be owner of token 1");
        assertEq(nft.tokenURI(1), METADATA_URI, "Token URI should match metadata");
    }

    function test_RevertMintByNonRelayer() public {
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(VisitorNFT.VisitorNFT__Unauthorized.selector));
        nft.entryMint(user1, METADATA_URI);
    }

    function test_RevertMintToAlreadyOwningAddress() public {
        vm.startPrank(relayer);
        nft.entryMint(user1, METADATA_URI); 
        vm.expectRevert(abi.encodeWithSelector(VisitorNFT.VisitorNFT__CantOwnMoreThanOne.selector));
        nft.entryMint(user1, METADATA_URI);
        vm.stopPrank();
    }

    function test_RevertMintToZeroAddress() public {
        vm.prank(relayer);
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidOwner.selector, address(0))); // InvalidOwner because balanceOf check for address(0)
        nft.entryMint(address(0), METADATA_URI);
    }


    function test_UpdateRelayer() public {
        vm.prank(owner);
        nft.setRelayer(user2);
        assertEq(nft.getRelayer(), user2, "Relayer should be updated to user2");
    }


    function test_RevertUpdateRelayerByNonOwner() public {
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user1));
        nft.setRelayer(user2);
    }

    function test_UpdateBaseURI() public {
        string memory newBaseURI = "https://newbase.com/";
        vm.prank(owner);
        nft.setTokenBaseURI(newBaseURI);

        vm.prank(relayer);
        nft.entryMint(user1, "");
        assertEq(
            nft.tokenURI(1),
            string(abi.encodePacked(newBaseURI, "1")),
            "Token URI should reflect updated base URI"
        );
    }

    function test_RevertTokenURIForNonExistentToken() public {
        vm.expectRevert("ERC721: URI query for nonexistent token");
        nft.tokenURI(999);
    }

    function test_MintMultipleNFTs() public {
        vm.startPrank(relayer);
        nft.entryMint(user1, METADATA_URI);
        nft.entryMint(user2, "ipfs://QmTestMetadata456");
        vm.stopPrank();

        assertEq(nft.totalMinted(), 2, "Total minted should be 2");
        assertEq(nft.balanceOf(user1), 1, "User1 should have 1 NFT");
        assertEq(nft.balanceOf(user2), 1, "User2 should have 1 NFT");
        assertEq(nft.tokenURI(2), "ipfs://QmTestMetadata456", "Token 2 URI should match");
    }

    function test_BaseURIFallback() public {
        vm.prank(relayer);
        nft.entryMint(user1, "");
        assertEq(
            nft.tokenURI(1),
            string(abi.encodePacked(BASE_URI, "1")),
            "Token URI should use base URI when no specific URI is set"
        );
    }
}