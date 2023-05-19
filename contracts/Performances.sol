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

contract Performances is ERC721, ERC721Enumerable, Pausable, Ownable {

    using Address for address payable;

    //URI
    string public baseURI;
    string public collectionURI;

    //address public serverAddress;
    uint public mintPriceInEuro = 390;
    uint256 public maxSupply = 25;

    //ORACLE TO HAVE PRICE
    AggregatorV3Interface internal priceFeed_ETHUSD;
    AggregatorV3Interface internal priceFeed_EURUSD;


    constructor(string memory _name, string memory _symbol, string memory _baseURI, address _priceFeedETHUSD, address _priceFeedEURUSD) ERC721(_name, _symbol) {

        baseURI = _baseURI;
        priceFeed_ETHUSD = AggregatorV3Interface(_priceFeedETHUSD); //0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        priceFeed_EURUSD = AggregatorV3Interface(_priceFeedEURUSD); //0xb49f677943BC038e9857d61E7d053CaA2C1734C1

    }


    function NFTMint(address _to, uint256 tokenId) public payable onlyOwner {

        uint256 mintPriceInEther = getTokenPriceInETH();
        require(msg.value >= mintPriceInEther, "Insufficient funds");

        require(tokenId < maxSupply, "Max supply reached");
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


    //GETTERS

    function getLatestPriceEURUSD() private view returns (uint256) {
        (, int256 price, , , ) = priceFeed_EURUSD.latestRoundData();
        return uint256(price);
    }

    function getLatestPriceETHUSD() private view returns (uint256) {
        (, int256 price, , , ) = priceFeed_ETHUSD.latestRoundData();
        return uint256(price);
    }


    function getTokenPriceInETH() public view returns (uint256) {
        // Get rate for EUR/USD
        uint256 priceEurUsd = getLatestPriceEURUSD();
        // Get rate for ETH/USD
        uint256 priceEthUsd = getLatestPriceETHUSD();

        //check if there is any error price
        require(priceEurUsd > 0, "EUR/USD price feed error");
        require(priceEthUsd > 0, "ETH/USD price feed error");

        // Convert price in US Dollar
        uint256 priceInUsd = (mintPriceInEuro * priceEurUsd) / 10**(priceFeed_EURUSD.decimals());

        // Convert price in Ether for US Dollar price
        uint256 priceInEth = (priceInUsd * 10**(priceFeed_ETHUSD.decimals()) * 10**18) / priceEthUsd;

        return priceInEth;
    }

    //OTHER FUNCTIONS


    function tokenURI(uint256 tokenId) public view virtual override(ERC721) returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(baseURI, Strings.toString(tokenId), ".json"));
    }

    //function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual   { }
    function burn(uint256 tokenId) external {
        _burn(tokenId);
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
