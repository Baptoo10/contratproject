// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract LaisserPasser is ERC1155, Pausable, Ownable, ERC1155Supply {

    //URI
    string public baseURI;
    string public collectionURI;

    string public collectionName;

    //supply
    uint256 public maxSupply = 50;

    //minter
    address public minter;


    constructor(string memory _collectionName, string memory _baseURI) ERC1155(_baseURI) {

        collectionName = _collectionName;

    }


    function NFTMint(address _to, uint256 tokenId, uint256 amount) public onlyOwner {

        require(msg.sender == minter || msg.sender == owner(), "you're not the minter");
        require(tokenId < maxSupply, "Max supply reached");
        require(tokenId > 0, "Id starts at 1"); //or require(tokenId >= 0, "Id starts at 0");

        _mint(_to, tokenId, amount, "");

    }

    function mintBatch(address to, uint256[] memory tokenIds, uint256[] memory amounts, bytes memory data) public onlyOwner {

        require(msg.sender == minter || msg.sender == owner(), "you're not the minter");
        require(tokenIds.length == amounts.length, "Array length mismatch");

        for(uint256 i=0 ; i<tokenIds.length ; i++){
            require(tokenIds[i] < maxSupply, "Max supply reached");
            require(tokenIds[i] > 0, "Id starts at 1"); //or require(tokenId >= 0, "Id starts at 0");
        }

        _mintBatch(to, tokenIds, amounts, data);
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

    function burn( address account, uint256 tokenId, uint256 amount) public virtual {
        require(account == _msgSender(),"ERC1155: caller is not token owner");
        _burn(account, tokenId, amount);
    }

    function burnBatch(address account, uint256[] memory tokenIds, uint256[] memory amounts) public virtual {
        require(account == _msgSender(), "ERC1155: caller is not token owner");
        _burnBatch(account, tokenIds, amounts);
    }



    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory tokenIds, uint256[] memory amounts, bytes memory data)
    internal
    whenNotPaused
    override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, tokenIds, amounts, data);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}