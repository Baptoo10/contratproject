// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Tricks is ERC721Enumerable, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    string public baseURI;
    address public serverAddress;
    uint public mintPrice = 390;
    mapping(uint => address) public owners;
    mapping(uint => uint[]) public attributes;
    mapping(uint => uint[]) public privileges;

    uint256 public maxSupply = 50;
    bool paused = false;

    AggregatorV3Interface internal priceFeed_ETHUSD;
    AggregatorV3Interface internal priceFeed_EURUSD;

    constructor(string memory _name, string memory _symbol, string memory _baseURI) ERC721(_name, _symbol) {
        setBaseURI(_baseURI);
        priceFeed_ETHUSD = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        priceFeed_EURUSD = AggregatorV3Interface(0xb49f677943BC038e9857d61E7d053CaA2C1734C1);
    }

    //function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
    //   return super.supportsInterface(interfaceId);
    // }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function pause() public onlyOwner {
        paused = true;
    }

    function unpause() public onlyOwner {
        paused = false;
    }

    function getLatestPriceEURUSD() public view returns (int) {
        (
        uint80 roundID,
        int price,
        uint startedAt,
        uint timeStamp,
        uint80 answeredInRound
        ) = priceFeed_EURUSD.latestRoundData();
        return price;
    }

    function getLatestPriceETHUSD() public view returns (int) {
        (
        uint80 roundID,
        int price,
        uint startedAt,
        uint timeStamp,
        uint80 answeredInRound
        ) = priceFeed_ETHUSD.latestRoundData();
        return price;
    }


    function convertEurToEth(uint256 priceEur) public view returns (uint256) {
        int256 priceEurUsd = getLatestPriceEURUSD();
        int256 priceEthUsd = getLatestPriceETHUSD();

        require(priceEurUsd > 0, "EUR/USD price feed error");
        require(priceEthUsd > 0, "ETH/USD price feed error");

        uint256 priceEth = (priceEur * uint256(priceEurUsd)) / uint256(priceEthUsd);
        return priceEth;
    }

    function NFTMint(address _to, string memory _baseURI) public payable onlyOwner {

        uint256 mintPriceInEuros = 390;
        uint256 mintPriceInEther = convertEurToEth(mintPriceInEuros);

        require(msg.value >= mintPriceInEther, "Insufficient funds");

        require(!paused);

        uint256 supply = totalSupply();
        require(supply <= maxSupply);

        // Mince le NFT
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(_to, tokenId);

    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721) returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(baseURI, Strings.toString(tokenId), ".json"));
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual   { }


    function _burn(uint256 tokenId) internal virtual override(ERC721) {

        // Call the _beforeTokenTransfer function
        _beforeTokenTransfer(address(0), address(0), tokenId);

        super._burn(tokenId);
    }
}