// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC721, ERC721} from "@openzeppelin/token/ERC721/ERC721.sol";

contract VisitorNFT is ERC721 {

    event VisitorNFT__Minted(address receiver, uint256 id);
    error VisitorNFT__MaxSupplyReached();
    error VisitorNFT__MintFailed();
    error VisitorNFT__CantOwnMoreThanOne();
    

    uint8 constant MAX_SUPPLY = 200;
    uint8 public totalMinted = 0;

    constructor() ERC721("Visitor", "VNFT") {}    

    function mint() external {
        if (ERC721.balanceOf(msg.sender) >= 1) {
            revert VisitorNFT__CantOwnMoreThanOne();
        }
        if (totalMinted >= MAX_SUPPLY) {
            revert VisitorNFT__MaxSupplyReached();
        }
        
        totalMinted++; 
        uint8 tokenid = totalMinted;
        
        try this.internalMint(msg.sender, tokenid) {
            emit VisitorNFT__Minted(msg.sender, tokenid);
            
        } catch {
            totalMinted--;
            revert VisitorNFT__MintFailed();
        }
    }


    function internalMint(address to, uint256 tokenId) internal {
        require(msg.sender == address(this), "Only internal calls");
        _mint(to, tokenId);
    }
    

}