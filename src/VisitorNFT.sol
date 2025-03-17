// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract VisitorNFT is ERC721, Ownable {
    using Strings for uint256;

    error VisitorNFT__MaxSupplyReached();
    error VisitorNFT__CantOwnMoreThanOne();
    error VisitorNFT__Unauthorized();

    // uint16 public constant MAX_SUPPLY = 1000;
    uint256 public totalMinted = 0;
    string private _baseTokenURI;
    mapping(uint256 => string) private _tokenURIs;
    address public relayer; // Relayer address

    constructor(string memory baseURI, address _relayer) ERC721("Visitor", "VNFT") Ownable(msg.sender) {
        _baseTokenURI = baseURI;
        relayer = _relayer; 
    }

    /*** GETTERS ***/

    /// @notice Return BaseURI
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    /// @notice Return tokenURI
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "ERC721: URI query for nonexistent token");
        string memory specificURI = _tokenURIs[tokenId];
        return bytes(specificURI).length > 0 ? specificURI : string(abi.encodePacked(_baseURI(), tokenId.toString()));
    }

    /*** ADMIN ***/

    /// @notice Change relayer Address
    function setRelayer(address _relayer) external onlyOwner {
        relayer = _relayer;
    }

    /// @notice Change baseURI 
    function setTokenBaseURI(string memory baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    /*** MINTING ***/

    /// @notice Mint NFT 
    function entryMint(address to, string calldata metadataURI) external {
        if (msg.sender != relayer) {
            revert VisitorNFT__Unauthorized();
        }
        if (balanceOf(to) >= 1) {
            revert VisitorNFT__CantOwnMoreThanOne(); // ERC721.balanceOf() checks for address(0)
        }
        /*if (totalMinted >= MAX_SUPPLY) {
            revert VisitorNFT__MaxSupplyReached();
        }*/

        totalMinted++;
        uint256 tokenId = totalMinted;
 
        // Mint 
        _safeMint(to, tokenId); // Emits the 'transfer' event read by the websocket
        _tokenURIs[tokenId] = metadataURI;

    }

}



