// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title a Crypto-Money to buy stickers' packages of world cup
/// @author @mrti259/@saantim/@ovr4ulin
/// @notice You can use this contract to mint FiubaCoins
/// @dev This contract inherits ERC20 interface
contract FiubaCoin is ERC20 {
    address owner;
    uint256 public mintPrice = 1000000 gwei; 

    constructor() ERC20("FiubaCoin", "FIU") {
        owner = msg.sender;
    }

    /// @notice This function sends the contract's ether to the contract's owner
    /// @dev The contract's owner can not be modified
    function withdraw() public {
        payable(owner).transfer(address(this).balance);
    }

    /// @notice You can use this function to buy `quantity` of FiubaCoins.
    /// @dev If the user doesn't send the correct amount of ether, then the function returns an errorIf the user doesn't send the correct amount then the function returns an error
    /// @param quantity It's the quantity of FiubaCoins to be minted
    function getFiubaCoin(uint256 quantity) public payable {
        require(quantity * mintPrice == msg.value, "wrong amount sent");
        _mint(msg.sender, quantity * 10 ** 18);
    }
}