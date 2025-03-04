// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC721, ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import  {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ECDSA} from   "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol"; 

contract VisitorNFT is ERC721, Ownable {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;
    using Strings for uint256; 

    event VisitorNFT__Minted(address receiver, uint256 id);
    error VisitorNFT__MaxSupplyReached();
    error VisitorNFT__MintFailed();
    error VisitorNFT__CantOwnMoreThanOne();
    error VisitorNFT__InvalidSignature();

    uint16 public constant MAX_SUPPLY = 500;
    uint8 public totalMinted = 0;
    
    string private _baseTokenURI;
    
    constructor() ERC721("Visitor", "VNFT") Ownable(msg.sender) {}
    
    function setBaseURI(string memory _baseURI) external onlyOwner {
        _baseTokenURI = _baseURI;
    }
    
    function baseURI() public view returns (string memory) {
        return _baseTokenURI;
    }
    
    function entryMint(bytes calldata signature) external {
        // Verify the signature so only the website can call this
        bytes32 messageHash = keccak256(abi.encodePacked(msg.sender));
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(messageHash);
        address signer = ECDSA.recover(ethSignedMessageHash, signature);
        
        if (signer != owner()) {
            revert VisitorNFT__InvalidSignature();
        }

        if (ERC721.balanceOf(msg.sender) >= 1) {
            revert VisitorNFT__CantOwnMoreThanOne();
        }
        
        if (totalMinted >= MAX_SUPPLY) {
            revert VisitorNFT__MaxSupplyReached();
        }
        
        totalMinted++; 
        uint8 tokenId = totalMinted;
        
        try this.performMint(msg.sender, tokenId) {
            emit VisitorNFT__Minted(msg.sender, tokenId);
        } catch {
            totalMinted--;
            revert VisitorNFT__MintFailed();
        }
    }

    function performMint(address to, uint256 tokenId) external {
        require(msg.sender == address(this), "Only internal calls");
        _safeMint(to, tokenId);
    }
}