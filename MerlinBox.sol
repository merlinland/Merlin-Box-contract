// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./ERC1420.sol";
import "./ERC1420Mirror.sol";
import {Ownable} from "./Ownable.sol";
import {LibString} from "./LibString.sol";
import {SafeTransferLib} from "./SafeTransferLib.sol";



contract MerlinBox is DN404, Ownable {
    string private _name = "MerlinBox";
    string private _symbol = "MerlinBox";
    string private _baseURI = "ipfs://bafybeiexo25xyawqdjbij5ayv5ykyltvtobyvvlaxm2sqnvojxgnki3fnu/";

    uint256 public constant BoxMaxSupply = 10000 ; 
    uint256 public constant TokenMaxSupply = 10000 * 10 ** 18; 

    uint256 public mintPriceL1 = 0.00035 ether;
    uint256 public mintPriceL2 = 0.000455 ether;
    uint256 public mintPriceL3 = 0.000592 ether;
    uint256 public mintPriceL4 = 0.000769 ether;
    uint256 public mintPriceL5 = 0.001 ether;

    address public  LPbotAddress = 0xF6a021CD6E76f1513b08B8AecA9D11081dcB12f8; 
    uint256 public  AddLPthreshold = 0.02 ether; 


    constructor() {
        _initializeOwner(msg.sender);
        address mirror = address(new DN404Mirror(msg.sender));
        _initializeDN404(55 * 10 ** 18, msg.sender, mirror);
       
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }


   function mint(uint256 mintAmount) public payable {

    require(mintAmount <= 20, "mintAmount exceeds the maxmint limit");

    uint256 currentSupply = totalSupply();
    uint256 mintPrice;
   
      if (currentSupply <=  2000 * 10 ** 18) {
        mintPrice = mintPriceL1;
    } else if (currentSupply <=  4000 * 10 ** 18) {
        mintPrice = mintPriceL2;
    } else if (currentSupply <=  6000 * 10 ** 18) {
        mintPrice = mintPriceL3;
    } else if (currentSupply <=  8000 * 10 ** 18) {
        mintPrice = mintPriceL4;
    } else if (currentSupply <=  10000 * 10 ** 18) {
        mintPrice = mintPriceL5;
    } else {
        revert("Minting would exceed max supply");
    }
   
    require(msg.value >= mintPrice * mintAmount, "Not enough ETH sent; check price");
    require(currentSupply + mintAmount * 10 ** 18 <= TokenMaxSupply, "Minting would exceed max supply");
    
    _mint(msg.sender, mintAmount * 10 ** 18);

 
    uint256 contractBalance = address(this).balance;
    if (contractBalance > AddLPthreshold) {
        uint256 botAmount = (contractBalance * 30) / 100; 
        uint256 ownerAmount = contractBalance - botAmount; 
        
        (bool sentToBot, ) = LPbotAddress.call{value: botAmount}("");
        require(sentToBot, "Failed to send BTC to bot");
        (bool sentToOwner, ) = owner().call{value: ownerAmount}("");
        require(sentToOwner, "Failed to send BTC to owner");
    }
   }


    function tokenURI(uint256 tokenId) public view override returns (string memory result) {
    require(tokenId >= 1 && tokenId <= BoxMaxSupply, "Box ID does not exist");
    uint8 seed = uint8(bytes1(keccak256(abi.encodePacked(tokenId))));
    string memory image;
    string memory info;

    if (seed <= 25) {
        image = "transmit.png";
        info = "Create a teleportation array";
    } else if (seed <= 64) {
        image = "build.png";
        info = "Build a city";
    } else if (seed <= 140) {
        image = "register.png";
        info = "Register business entity";
    } else {
        image = "merge.png";
        info = "Merge land";
    }
    
    string memory jsonPreImage = string(
        abi.encodePacked(
            '{"name": "MerlinBox #', 
            LibString.toString(tokenId),
            '","description":"The magical Merlin Box, with the Merlin Box you can build a sandbox Merlin Metaverse, running on the ERC-1420 protocol","external_url":"https://merlinland.pro","image":"',
            _baseURI,
            image
        )
    );
    string memory jsonPostImage = string(abi.encodePacked(
        '","attributes":[{"trait_type":"Tick","value":"Box"},{"trait_type":"Info","value":"',
        info
    ));
    string memory jsonPostTraits = '"}]}';

    string memory json = string(
        abi.encodePacked(
            "data:application/json;utf8,",
            abi.encodePacked(
                abi.encodePacked(jsonPreImage, jsonPostImage),
                jsonPostTraits
            )
        )
    );

    return json;
   }


    function setBaseURI(string calldata baseURI_) public onlyOwner {
        _baseURI = baseURI_;
    }

    function withdraw() public onlyOwner {
        SafeTransferLib.safeTransferAllETH(msg.sender);
    }


    function setMintPriceL1(uint256 newPrice) public onlyOwner {
        mintPriceL1 = newPrice;
    }

    function setMintPriceL2(uint256 newPrice) public onlyOwner {
        mintPriceL2 = newPrice;
    }

    function setMintPriceL3(uint256 newPrice) public onlyOwner {
        mintPriceL3 = newPrice;
    }

    function setMintPriceL4(uint256 newPrice) public onlyOwner {
        mintPriceL4 = newPrice;
    }

    function setMintPriceL5(uint256 newPrice) public onlyOwner {
        mintPriceL5 = newPrice;
    }

    function setLPBotAddress(address newLPBotAddress) public onlyOwner {
        require(newLPBotAddress != address(0), "Invalid address: cannot be zero address");
        LPbotAddress = newLPBotAddress;
    }

    function setAddLPthreshold(uint256 newThreshold) public onlyOwner {
        require(newThreshold > 0, "Invalid threshold: must be greater than 0");
        AddLPthreshold = newThreshold;
    }

 
}