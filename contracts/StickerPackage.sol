// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface FiubaCoinInterface {
  function transferFrom(address _from, address _to, uint _amount) external;
}

interface StickerInterface {
  function createStickers(address _address, uint _amount) external;
}

contract StickerPackageContract is Ownable {
  using SafeMath for uint;
  address coinAddress;
  address stickerAddress;
  uint price;
  uint stickersPerPackages = 5;
  
  mapping(address => uint) packagesFromUser;

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
  
  function setFiubaCoinAddress(address _coinAddress) external onlyOwner {
    coinAddress = _coinAddress;
  }

  function setStickerAddress(address _stickerAddress) external onlyOwner {
    stickerAddress = _stickerAddress;
  }

  function buyPackages(uint _quantity) external withPriceSetted {
    FiubaCoinInterface(coinAddress).transferFrom(
      msg.sender,
      address(this),
      _quantity * price
    );
    packagesFromUser[msg.sender] = packagesFromUser[msg.sender].add(_quantity);
  }

  function openPackage() external {
    require(packagesFromUser[msg.sender] > 0);
    StickerInterface(stickerAddress).createStickers(msg.sender, stickersPerPackages);
    packagesFromUser[msg.sender] = packagesFromUser[msg.sender].sub(1);
  }

  function getAmountOfPackagesFrom(address _owner) external view returns (uint) {
    return packagesFromUser[_owner];
  }
}