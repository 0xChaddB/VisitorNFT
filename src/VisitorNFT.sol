// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC721} from "@openzeppelin/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {Strings} from "@openzeppelin/utils/Strings.sol";

/**
 * @title VisitorNFT
 * @dev ERC-721 contract for minting unique visitor badges with custom metadata URIs, restricted to a relayer.
 */
contract VisitorNFT is ERC721, Ownable {
    using Strings for uint256;

    error VisitorNFT__CantOwnMoreThanOne();
    error VisitorNFT__Unauthorized();

    uint256 public totalMinted = 0; // Total number of NFTs minted
    string private _baseTokenURI;   // Base URI for token metadata
    mapping(uint256 => string) private _tokenURIs; // Mapping of tokenId to specific metadata URI
    address public relayer;         // Address authorized to mint (relayer)

    /**
     * @notice Initializes the contract with a base URI and relayer address.
     * @param baseURI The base URI for token metadata (can be overridden by specific URIs).
     * @param _relayer The address allowed to call the mint function.
     */
    constructor(string memory baseURI, address _relayer) 
        ERC721("Visitor", "VNFT") 
        Ownable(msg.sender) 
    {
        _baseTokenURI = baseURI;
        relayer = _relayer;
    }

    /*** MINTING ***/

    /**
     * @notice Mints a new NFT to the specified address with a custom metadata URI.
     * @dev Only the relayer can call this function. One NFT per address limit enforced.
     * @param to The recipient address of the NFT.
     * @param metadataURI The URI pointing to the NFT's metadata (e.g., IPFS link).
     */
    function entryMint(address to, string calldata metadataURI) external {
        
        if (msg.sender != relayer) {
            revert VisitorNFT__Unauthorized();
        }
        if (balanceOf(to) >= 1) {  // BalanceOf Revert with ERC721InvalidOwner(address) if to == address !
            revert VisitorNFT__CantOwnMoreThanOne();  
        }

        unchecked { totalMinted++; }
        uint256 tokenId = totalMinted; 

        _safeMint(to, tokenId); // Emit Transfer event read by Websocket
        _tokenURIs[tokenId] = metadataURI; 
    }

    /*** ADMIN FUNCTIONS ***/

    /**
     * @notice Updates the relayer address (only callable by owner).
     * @param _relayer The new relayer address.
     */
    function setRelayer(address _relayer) external onlyOwner {
        relayer = _relayer;
    }

    /*** GETTERS ***/
    /**
     * @notice Returns the URI for a specific token, prioritizing specific URI over base URI.
     * @param tokenId The ID of the token to query.
     * @return The token's metadata URI.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "ERC721: URI query for nonexistent token");
        string memory specificURI = _tokenURIs[tokenId];
        return bytes(specificURI).length > 0 
            ? specificURI 
            : string(abi.encodePacked(_baseURI(), tokenId.toString()));
    }
}