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

contract Tricks is ERC721Enumerable, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    string public baseURI;
    address public serverAddress;
    uint public mintPrice = 390;
    address[] owners;
    mapping(uint => uint[]) public attributes;
    mapping(uint => uint[]) public privileges;

    uint256 public maxSupply = 50;
    bool paused = false;

    AggregatorV3Interface internal priceFeed_ETHUSD;
    AggregatorV3Interface internal priceFeed_EURUSD;

    struct NFTAttributes {
        uint256 femme;
        uint256 handi;
        uint256 homme;
        uint256 lancerBalayer;
        uint256 tricks2;
        uint256 tricks3;
        uint256 tricks4;
        uint256 tricks1;
    }

    struct NFTPrivileges {
        uint256 bronze;
        uint256 argent;
        uint256 or;
        uint256 platine;
    }


    mapping(uint256 => NFTAttributes) private _tokenAttributes;
    mapping(uint256 => NFTPrivileges) private _tokenPrivileges;


    constructor(string memory _name, string memory _symbol, string memory _baseURI) ERC721(_name, _symbol) {
        setBaseURI(_baseURI);
        priceFeed_ETHUSD = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        priceFeed_EURUSD = AggregatorV3Interface(0xb49f677943BC038e9857d61E7d053CaA2C1734C1);
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function pause() public onlyOwner {
        paused = true;
    }

    function unpause() public onlyOwner {
        paused = false;
    }

    function getLatestPriceEURUSD() public view returns (int) {
        (, int256 price, , , ) = priceFeed_EURUSD.latestRoundData();
        return price;
    }

    function getLatestPriceETHUSD() public view returns (int) {
        (, int256 price, , , ) = priceFeed_ETHUSD.latestRoundData();
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
    /**
        function NFTMint(address _to, string memory _NFTURI) public payable onlyOwner {

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
    */




    //en fonction de la valeur "attribute" existante dans le fichier .json de chaque NFT
    function setTokenAttributesByURI(string memory _tokenURI) internal onlyOwner {

        uint256 tokenId = getTokenIdByURI(_tokenURI);
        require(_exists(tokenId), "ERC721Metadata: L'URI associee au token n'existe pas. Le token n'existe donc pas.");

        // Parcourir les attributs dans le fichier JSON correspondant a l'URI du token
        //Stocker les data dans la struct NFTAttributes

        NFTAttributes memory newAttributes;

        _tokenAttributes[tokenId] = newAttributes;
    }


    function getTokenAttributesByURI(string memory _tokenURI) public view returns (NFTAttributes memory) {

        uint256 tokenId = getTokenIdByURI(_tokenURI);
        require(_exists(tokenId), "ERC721Metadata: L'URI associee au token n'existe pas. Le token n'existe donc pas.");

        return _tokenAttributes[tokenId];

    }


    //en fonction de la valeur "privileges" existante dans le fichier .json de chaque NFT
    function setTokenPrivilegesByURI(string memory _tokenURI) internal onlyOwner {

        uint256 tokenId = getTokenIdByURI(_tokenURI);
        require(_exists(tokenId), "ERC721Metadata: L'URI associee au token n'existe pas. Le token n'existe donc pas.");

        // Parcourir les privileges dans le fichier JSON correspondant a l'URI du token
        //Stocker les data dans la struct NFTPrivileges

        NFTPrivileges memory newPrivileges;

        _tokenPrivileges[tokenId] = newPrivileges;
    }


    function getTokenPrivilegesByURI(string memory _tokenURI) public view returns (NFTPrivileges memory) {

        // Parcourir les privileges dans le fichier JSON correspondant a l'URI du token
        //Stocker les data dans le tableau tokenPrivileges
        //Retourner le tableau

        uint256 tokenId = getTokenIdByURI(_tokenURI);
        require(_exists(tokenId), "ERC721Metadata: L'URI associee au token n'existe pas. Le token n'existe donc pas.");

        return _tokenPrivileges[tokenId];
    }





    function tokenURI(uint256 tokenId) public view virtual override(ERC721) returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(baseURI, Strings.toString(tokenId), ".json"));
    }

    function getTokenIdByURI(string memory _tokenURI) public view returns (uint256) {
        uint256 totalTokens = totalSupply();
        for (uint256 tokenId = 0; tokenId < totalTokens; tokenId++) {
            if (compareStrings(_tokenURI, tokenURI(tokenId))) {
                return tokenId;
            }
        }
        revert("Le token n'existe pas pour l'URI donnee en parametre");
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }


    //function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual   { }


    function _burn(uint256 tokenId) internal virtual override(ERC721) {

        // Call the _beforeTokenTransfer function
        _beforeTokenTransfer(address(0), address(0), tokenId);

        super._burn(tokenId);
    }


    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual {
        super._beforeTokenTransfer(from, to, tokenId, 1); //batchSize specifie combien de jetons sont transferes
        // dans un seul lot. Ici on transfere un seul token a la fois, donc la valeur de batchSize est 1.

        require(to != address(0), "ERC721: transaction a l'adresse 0x");
    }

    /// MINT ///
    function NFTMint(address _to, string memory _NFTURI) public payable onlyOwner {
        uint256 mintPriceInEuros = 390;
        uint256 mintPriceInEther = convertEurToEth(mintPriceInEuros);

        require(msg.value >= mintPriceInEther, "Insufficient funds");
        require(!paused);

        uint256 supply = totalSupply();
        require(supply < maxSupply);

        // Mint le NFT
        uint256 tokenId = getTokenIdByURI(_NFTURI);
        //verification avec la fonction _beforeTokenTransfer
        _beforeTokenTransfer(address(0), _to, tokenId);

        //Mint
        _safeMint(_to, tokenId);
        owners.push(_to);

        setTokenAttributesByURI(_NFTURI);
        setTokenPrivilegesByURI(_NFTURI);
    }
}

