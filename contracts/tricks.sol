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

contract Tricks is ERC721, ERC721Enumerable, Pausable, Ownable {

    using Address for address payable;
    //using Counters for Counters.Counter;

    //Counters.Counter private _tokenIdCounter;

    //URI
    string public baseURI;
    string private collectionURI;
    //mapping(string => uint256) private uriToTokenId;

    //address public serverAddress;
    uint public mintPriceInEuro = 390;
    uint256 public maxSupply = 50;

    //OTHER VAR
    address[] owners;
    //bool paused = false;

    //ORACLE TO HAVE PRICE
    AggregatorV3Interface internal priceFeed_ETHUSD;
    AggregatorV3Interface internal priceFeed_EURUSD;

    /*    //ATTRIBUTES & PRIVILEGES
        mapping(uint256 => NFTAttributes) private _tokenAttributes;
        mapping(uint256 => NFTPrivileges) private _tokenPrivileges;

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

    */



    constructor(string memory _name, string memory _symbol, string memory _baseURI, address _priceFeedETHUSD, address _priceFeedEURUSD) ERC721(_name, _symbol) {

        setBaseURI(_baseURI);
        priceFeed_ETHUSD = AggregatorV3Interface(_priceFeedETHUSD);
        priceFeed_EURUSD = AggregatorV3Interface(_priceFeedEURUSD);

        /*
        priceFeed_ETHUSD = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        priceFeed_EURUSD = AggregatorV3Interface(0xb49f677943BC038e9857d61E7d053CaA2C1734C1);
        */

    }


    function NFTMint(address _to, uint256 tokenId) public payable onlyOwner {

        uint256 mintPriceInEther = getTokenPriceInETH();
        require(msg.value >= mintPriceInEther, "Insufficient funds");

        // require(!paused, "Contract is paused");

        // uint256 supply = totalSupply();
        require(tokenId < maxSupply, "Max supply reached");
        require(tokenId > 0, "Id starts at 1"); //or require(tokenId >= 0, "Id starts at 0");

        _safeMint(_to, tokenId);
        owners.push(_to);

        //  setTokenAttributesByURI(tokenId);
        //  setTokenPrivilegesByURI(tokenId);
    }


    //SETTERS
    //To change the base URI //Allows the contract owner to modify the base URL of the metadata of the NFTs in the collection.
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    //To change the contract URI //Allows the contract owner to modify the URL of the contract itself, containing additional information about the contract.
    function setContractURI(string memory uri) external onlyOwner {
        collectionURI = uri;
    }


    /*
        //en fonction de la valeur "attribute" existante dans le fichier .json de chaque NFT
        function setTokenAttributesByURI(string memory _tokenURI) internal onlyOwner {

            uint256 tokenId = getTokenIdByURI(_tokenURI);
            require(_exists(tokenId), "ERC721Metadata: L'URI associee au token n'existe pas. Le token n'existe donc pas.");

            // Parcourir les attributs dans le fichier JSON correspondant a l'URI du token
            //Stocker les data dans la struct NFTAttributes

            NFTAttributes memory newAttributes;

            _tokenAttributes[tokenId] = newAttributes;
        }
    */


    /*
        function setTokenAttributesByTokenID(uint256 _tokenID) internal onlyOwner {
            require(_exists(_tokenID), "ERC721Metadata: Le token ID n'existe pas.");

            // Parcourir les attributs dans le fichier JSON correspondant à l'URI du token
            // Stocker les données dans la struct NFTAttributes

            NFTAttributes memory newAttributes;

            _tokenAttributes[_tokenID] = newAttributes;
        }



        function setTokenPrivilegesByTokenID(uint256 _tokenID) internal onlyOwner {
            require(_exists(_tokenID), "ERC721Metadata: Le token ID n'existe pas.");

            // Parcourir les privileges dans le fichier JSON correspondant à l'URI du token
            // Stocker les données dans la struct NFTPrivileges

            NFTPrivileges memory newPrivileges;

            _tokenPrivileges[_tokenID] = newPrivileges;
        }
    */

    /*
        //en fonction de la valeur "privileges" existante dans le fichier .json de chaque NFT
        function setTokenPrivilegesByURI(string memory _tokenURI) internal onlyOwner {

            uint256 tokenId = getTokenIdByURI(_tokenURI);
            require(_exists(tokenId), "ERC721Metadata: L'URI associee au token n'existe pas. Le token n'existe donc pas.");

            // Parcourir les privileges dans le fichier JSON correspondant a l'URI du token
            //Stocker les data dans la struct NFTPrivileges

            NFTPrivileges memory newPrivileges;

            _tokenPrivileges[tokenId] = newPrivileges;
        }
    */



    //GETTERS

    function getContractURI() public view returns (string memory) {
        return collectionURI;
    }

    function getBaseURI() public view returns (string memory) {
        return baseURI;
    }


    function getLatestPriceEURUSD() private view returns (uint256) {
        (, int256 price, , , ) = priceFeed_EURUSD.latestRoundData();
        return uint256(price);
    }

    function getLatestPriceETHUSD() private view returns (uint256) {
        (, int256 price, , , ) = priceFeed_ETHUSD.latestRoundData();
        return uint256(price);
    }

    /*
        function convertEurToEth(uint256 priceEur) public view returns (uint256) {

            uint256 priceEurUsd = getLatestPriceEURUSD();
            uint256 priceEthUsd = getLatestPriceETHUSD();

            require(priceEurUsd > 0, "EUR/USD price feed error");
            require(priceEthUsd > 0, "ETH/USD price feed error");

            uint256 priceEth = (priceEur * uint256(priceEurUsd)) / uint256(priceEthUsd);
            return priceEth;
        }
    */

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

    /*
        function getTokenAttributesByID(uint256 _tokenID) public view returns (NFTAttributes memory) {

            // Browse the attributes in the JSON file corresponding to the token ID
            // Return the _tokenAttributes array for the token in question

            require(_exists(_tokenID), "ERC721Metadata: L'URI associee au token n'existe pas. Le token n'existe donc pas.");

            return _tokenAttributes[_tokenID];

        }

        function getTokenPrivilegesByID(uint256 _tokenID) public view returns (NFTPrivileges memory) {

            // Browse the privileges in the JSON file corresponding to the token ID
            // Return the _tokenPrivileges array for the token in question

            require(_exists(_tokenID), "ERC721Metadata: L'URI associee au token n'existe pas. Le token n'existe donc pas.");

            return _tokenPrivileges[_tokenID];
        }
    */

    /*function getTokenIdByURI(string memory _tokenURI) public view returns (uint256) {
        uint256 totalTokens = totalSupply();
        for (uint256 tokenId = 0; tokenId < totalTokens; tokenId++) {
            if (compareStrings(_tokenURI, tokenURI(tokenId))) {
                return tokenId;
            }
        }
        revert("Le token n'existe pas pour l'URI donnee en parametre");
    }*/
    /*function getTokenIdByURI(string memory _tokenURI) public view returns (uint256) {
        uint256 tokenId = uriToTokenId[_tokenURI];
        require(tokenId > 0, "ERC721Metadata: URI query for nonexistent token");

        return tokenId;
    }*/

    /* function getTokenIdByURI(string memory _URI) public view returns (uint256) {
     for (uint256 tokenId = 1; tokenId <= totalSupply(); tokenId++) {
         string memory tokenURI = string(abi.encodePacked(baseURI, "/", tokenId.toString(), ".json"));
         if (compareStrings(tokenURI, _URI)) {
             return tokenId;
         }
     }
     revert("Token with URI not found");
     }*/



    //OTHER FUNCTIONS

    //To pause fonctionnalities of the contract (where should we call the function ?)
    /*function pause() public onlyOwner {
        paused = true;
    }
    //To unpause
    function unpause() public onlyOwner {
        paused = false;
    }*//*
    function pause() public onlyOwner {
        pause();
    }

    function unpause() public onlyOwner {
        unpause();
    }*/

    function tokenURI(uint256 tokenId) public view virtual override(ERC721) returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(baseURI, Strings.toString(tokenId), ".json"));
    }


    // function compareStrings(string memory a, string memory b) internal pure returns (bool) {
    //   return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    //}



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

    /*  /// MINT ///
      function NFTMint(address _to, string memory _NFTURI) public payable onlyOwner {

          //uint256 mintPriceInEther = getTokenPriceInETH();

      require(msg.value >= 1 wei, "Insufficient funds");
          require(!paused);

          uint256 supply = totalSupply();
          require(supply < maxSupply);

          // Mint le NFT
         // uint256 tokenId = 1;

          //Mint
          _safeMint(_to, tokenId);
          //    this.safeTransferFrom(address(this), msg.sender, tokenId);
          owners.push(_to);

          // Mettre à jour le mapping uriToTokenId
          uriToTokenId[_NFTURI] = tokenId;

          setTokenAttributesByURI(_NFTURI);
          setTokenPrivilegesByURI(_NFTURI);
      }*/


}
