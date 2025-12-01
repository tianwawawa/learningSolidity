// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MyNFT is ERC721Enumerable {
    mapping(uint256=>string) internal _tokenURIs;
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}
    function mint(string memory tokenURI_) external {
        uint256 tokenId = totalSupply()+1;
        _tokenURIs[tokenId] = tokenURI_;
        _safeMint(msg.sender, tokenId);
    }

     function tokenURI(uint256 tokenId) public view override  returns (string memory) {
        _requireOwned(tokenId);
        return _tokenURIs[tokenId];
    }
}