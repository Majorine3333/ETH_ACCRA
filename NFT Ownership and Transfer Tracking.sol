/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NFTTracking {
    struct NFT {
        uint256 tokenId;
        address owner;
        string metadataURI;
    }

    mapping(uint256 => NFT) public nfts;
    mapping(address => uint256[]) public ownedTokens;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event MetadataUpdate(uint256 indexed tokenId, string metadataURI);

    uint256 private _nextTokenId;

    constructor() {
        _nextTokenId = 1; // Initialize tokenId to start from 1
    }

    function mint(string memory metadataURI) external {
        uint256 tokenId = _nextTokenId++;
        NFT storage nft = nfts[tokenId];
        nft.tokenId = tokenId;
        nft.owner = msg.sender;
        nft.metadataURI = metadataURI;
        
        ownedTokens[msg.sender].push(tokenId);

        emit Transfer(address(0), msg.sender, tokenId);
    }

    function transfer(address to, uint256 tokenId) external {
        require(nfts[tokenId].owner == msg.sender, "Only owner can transfer");
        require(to != address(0), "Cannot transfer to zero address");

        _removeTokenFromOwnerEnumeration(msg.sender, tokenId);
        nfts[tokenId].owner = to;
        ownedTokens[to].push(tokenId);

        emit Transfer(msg.sender, to, tokenId);
    }

    function updateMetadata(uint256 tokenId, string memory metadataURI) external {
        require(nfts[tokenId].owner == msg.sender, "Only owner can update metadata");

        nfts[tokenId].metadataURI = metadataURI;

        emit MetadataUpdate(tokenId, metadataURI);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        uint256 lastTokenIndex = ownedTokens[from].length - 1;
        uint256 tokenIndex = _findIndexOfToken(from, tokenId);

        // Swap the last token with the one being removed and then pop the array
        ownedTokens[from][tokenIndex] = ownedTokens[from][lastTokenIndex];
        ownedTokens[from].pop();
    }

    function _findIndexOfToken(address owner, uint256 tokenId) private view returns (uint256) {
        uint256[] storage tokens = ownedTokens[owner];
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == tokenId) {
                return i;
            }
        }
        revert("Token not found");
    }
}
