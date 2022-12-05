// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface FiubaCoinInterface {
    function transferFrom(address from, address to, uint256 amount) external;
}

interface QatanStickerInterface {
    function createStickers(address owner, uint256 amount) external;
}

/// @title  A Sticker Package's implementation
/// @author @mrti259/@saantim/@ovr4ulin
/// @notice You can use this contract to buy sticker packages using FiubaCoins, and you can use your packages to get stickers
/// @dev  You can set the FiubaCoin contract to buy packages and the Sticker contract to generate the stickers when you open a package
contract QatanStickerPackage is Ownable {
    using SafeMath for uint256;
    address coinAddress;
    address stickerAddress;
    uint256 public price;
    uint256 public stickersPerPackages = 5;

    mapping(address => uint256) packagesFromUser;

    constructor() {
        _setPrice(1);
    }

    /// @notice Set an amount of stickers you gonna get per package
    /// @dev This funtion sets the quantity of sticker per package and verify if the inserted amount as parameter is bigger than zero
    /// @param amount A new amount of stickers per package
    function setStickersPerPackage(uint256 amount) external onlyOwner {
        require(amount > 0);
        stickersPerPackages = amount;
    }

    /// @notice Set the price for one package
    /// @dev Only the owner of this contract could change the price
    /// @param newPrice New price of a package
    function setPrice(uint256 newPrice) external onlyOwner {
        _setPrice(newPrice);
    }

    function _setPrice(uint256 newPrice) private {
        price = newPrice;
    }

    /// @notice Set the FiubaCoin contract address
    /// @dev Only the owner of this contract could set this address
    /// @param newCoinAddress The FiubaCoin address to be setted
    function setCoinAddress(address newCoinAddress) external onlyOwner {
        coinAddress = newCoinAddress;
    }

    /// @notice Set the StickerAddress contract address
    /// @dev Only the owner of this contract could set this address
    /// @param newStickerAddress The Sticker address to be setted
    function setStickerAddress(address newStickerAddress) external onlyOwner {
        stickerAddress = newStickerAddress;
    }

    /// @notice You can buy quantity of packages using your FiubaCoins
    /// @dev Tries to transfer from FiubaCoin address the necesary FiubaCoins to get the required packages
    /// @param quantity The quantity of required packages to buy
    function buyPackages(uint256 quantity) external {
        require(price > 0, "New packages aren't available");
        FiubaCoinInterface(coinAddress).transferFrom(
            msg.sender,
            address(this),
            quantity * price
        );
        packagesFromUser[msg.sender] = packagesFromUser[msg.sender].add(
            quantity
        );
    }

    /// @notice You can open a package to get stickers
    /// @dev If the user have packages, you can get Stickers from this function
    function openPackage() external {
        require(packagesFromUser[msg.sender] > 0);
        QatanStickerInterface(stickerAddress).createStickers(
            msg.sender,
            stickersPerPackages
        );
        packagesFromUser[msg.sender] = packagesFromUser[msg.sender].sub(1);
    }

    /// @notice Get the amount of packages from an specify wallet
    /// @dev Access to a mapping to get the number of packages associated to an address
    /// @param owner Owner of address wallet
    /// @return amount Quantity of packages associated to a specify wallet
    function getAmountOfPackagesFrom(
        address owner
    ) external view returns (uint256) {
        return packagesFromUser[owner];
    }
}
