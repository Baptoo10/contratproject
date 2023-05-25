// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Tricks is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Pausable, Ownable {

    //URI
    string public baseURI;
    string public collectionURI;

    //supply
    uint256 public maxSupply = 25;

    //minter
    address public minter;


    constructor(string memory _name, string memory _symbol, string memory _baseURI) ERC721(_name, _symbol) {

        baseURI = _baseURI;

    }


    //voir pour modification si tout est a mint one shot
    function NFTMintById(address _to, uint256 tokenId) public {

        require(msg.sender == minter || msg.sender == owner(), "you're not the minter");
        require(tokenId < maxSupply, "Max supply reached"); //could be changed, depend on  the following line
        require(tokenId > 0, "Id starts at 1"); //or require(tokenId >= 0, "Id starts at 0");

        _safeMint(_to, tokenId);

    }


    //SETTERS
    //To change the base URI //Allows the contract owner to modify the base URL of the metadata of the NFTs in the collection.
    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    //To change the contract URI //Allows the contract owner to modify the URL of the contract itself, containing additional information about the contract.
    function setContractURI(string memory _uri) external onlyOwner {
        collectionURI = _uri;
    }

    //To change the contract max supply //Allows the contract owner to modify the max supply of the contract itself
    function setMaxSupply(uint256 _supp) external onlyOwner {
        maxSupply = _supp;
    }

    //To set a new mint address
    function setMinter(address _minter) external onlyOwner {
        minter=_minter;
    }



    //OTHER FUNCTIONS

    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(baseURI, Strings.toString(tokenId), ".json"));
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal whenNotPaused
    override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}