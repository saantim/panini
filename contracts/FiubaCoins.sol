// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FiubaCoin is ERC20 {
    address owner;
    uint256 public mintPrice = 1000000 gwei; 

    constructor() ERC20("FiubaCoin", "FIU") {
        owner = msg.sender;
    }

    function getNFiubaCoins(uint256 n) internal {
        _mint(msg.sender, n * 10 ** 18);
    }

    function withdraw() public {
        payable(owner).transfer(address(this).balance);
    }

    function getFiubaCoin(uint256 quantity) public payable {
        require(quantity * mintPrice == msg.value, "wrong amount sent");
        getNFiubaCoins(quantity);
    }

}