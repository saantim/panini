// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// import Ownable
// import SafeMath

interface Coin {
  function consume(uint _amount);
}

interface Sticker {
  function createSticker(address _address, uint _amount);
}

contract StickerPackageContract {
  using SafeMath for uint;

  address owner;
  address coinAddress;
  address stickerAddress;
  uint price;
  uint stickersPerPackages = 5;
  
  mapping(address => uint) packagesFromUser;

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(owner == msg.sender);
    _;
  }

  modifier withPriceSetted() {
    require(price > 0);
    _;
  }

  function setStickersPerPackage(uint _amount) external onlyOwner {
    require(_amount > 0);
    stickersPerPackages = _amount;
  }

  function setPrice(uint _price) external onlyOwner {
    price = _price; 
  }
  
  function setCoinAddress(address _coinAddress) external onlyOwner {
    coinAddress = _coinAddress;
  }

  function setStickerAddress(address _stickerAddress) external onlyOwner {
    stickerAddress = _stickerAddress;
  }

  function buyPackages(uint _quantity) external withPriceSetted {
    Coin coinContact = Coint(coinAddress).consume(_quantity * price);
    for(uint i; i < _quantity; i++) {
      packagesFromUser[msg.sender] = packagesFromUser[msg.sender].add(1);
    }
  }

  function openPackage() external {
    require(packagesFromUser[msg.sender] > 0);
    Sticker stickerContract = Sticker(stickerAddress).createStickers(msg.sender, stickersPerPackages);
    packagesFromUser[msg.sender] = packagesFromUser[msg.sender].sub(1);
  }

  function getAmountOfPackagesFrom(address _owner) external view returns (uint) {
    return packagesFromUser[_owner];
  }
}
