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

/// @title  A Sticker Package implementation
/// @author @mrti259/@saantim/@ovr4ulin
/// @notice You can use this contract to buy sticker packages using FiubaCoins, and you can use your packages to get stickers
/// @dev  You can set the FiubaCoin contract to buy packages and the Sticker contract to generate the stickers when you open a package
contract StickerPackageContract is Ownable {
  using SafeMath for uint;
  address coinAddress;
  address stickerAddress;
  uint price;
  uint stickersPerPackages = 5;
  
  mapping(address => uint) packagesFromUser;

  /// @dev Verify price is a positive non-zero value
  modifier withPriceSetted() {
    require(price > 0);
    _;
  }

  /// @notice Set an amount of stickers you gonna get per package
  /// @dev This funtion sets the quantity of sticker per package and verify if the inserted amount as parameter is bigger than zero
  /// @param _amount A new amount of stickers per package
  function setStickersPerPackage(uint _amount) external onlyOwner {
    require(_amount > 0);
    stickersPerPackages = _amount;
  }

  /// @notice Set the price for one package
  /// @dev Only the owner of this contract could change the price
  /// @param _price New price of a package
  function setPrice(uint _price) external onlyOwner {
    price = _price; 
  }
  
  /// @notice Set the FiubaCoin contract address
  /// @dev Only the owner of this contract could set this address
  /// @param _coinAddress The FiubaCoin address to be setted
  function setFiubaCoinAddress(address _coinAddress) external onlyOwner {
    coinAddress = _coinAddress;
  }

  /// @notice Set the StickerAddress contract address
  /// @dev Only the owner of this contract could set this address
  /// @param _stickerAddress The Sticker address to be setted
  function setStickerAddress(address _stickerAddress) external onlyOwner {
    stickerAddress = _stickerAddress;
  }

  /// @notice You can buy N-quantity of packages using your FiubaCoins
  /// @dev Tries to transfer from FiubaCoin address the necesary FiubaCoins to get the required packages
  /// @param _quantity The quantity of required packages to buy
  function buyPackages(uint _quantity) external withPriceSetted {
    FiubaCoinInterface(coinAddress).transferFrom(
      msg.sender,
      address(this),
      _quantity * price
    );
    packagesFromUser[msg.sender] = packagesFromUser[msg.sender].add(_quantity);
  }

  /// @notice You can open a package to get stickers
  /// @dev If the user have packages, you can get Stickers from this function
  function openPackage() external {
    require(packagesFromUser[msg.sender] > 0);
    StickerInterface(stickerAddress).createStickers(msg.sender, stickersPerPackages);
    packagesFromUser[msg.sender] = packagesFromUser[msg.sender].sub(1);
  }

  /// @notice Get the amount of packages from an specify wallet
  /// @dev Access to a mapping to get the number of packages associated to an address
  /// @param _owner Owner of address wallet 
  /// @return amount Quantity of packages associated to a specify wallet
  function getAmountOfPackagesFrom(address _owner) external view returns (uint) {
    return packagesFromUser[_owner];
  }
}