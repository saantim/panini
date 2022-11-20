//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract QatarSticker is ERC721, Ownable{
    
    // ---------------------------------------------------
    // public variables
    // ---------------------------------------------------
    uint256 public totalMints = 0;
    uint256 public mintPrice = 1000000 gwei; 
    string public URI = "https://bafybeifqmgyfy4by3gpms5sdv3ft3knccmjsqxfqquuxemohtwfm7y7nwa.ipfs.dweb.link/metadata.json";
    
    mapping(uint256 => uint256) public stickerToPlayer;
    mapping(uint256 => string) public playerToURI; 
    
    // ---------------------------------------------------
    // private variables
    // ---------------------------------------------------
    address private packageContractAddress;
    uint256 private maxPlayer = 711;

    // ---------------------------------------------------
    // configuration
    // ---------------------------------------------------
    function setPackageContractAddress(address newPackageContractAddress) public onlyOwner {
        packageContractAddress = newPackageContractAddress;
    }

    // ---------------------------------------------------
    // modifiers
    // ---------------------------------------------------
    modifier onlyPackageContract(){
        require(msg.sender == packageContractAddress);
        _;
    }

    // ---------------------------------------------------
    // functions
    // ---------------------------------------------------
    constructor() ERC721("QatarSticker", "QST") {
    }

    function createStickers(address packageOwner, uint256 quantity) public onlyPackageContract {
        for (uint i = 0; i < quantity; i++) {
            safeMint(packageOwner);
        }
    }

    function safeMint(address to) internal {
        uint tokenId = totalMints;
        stickerToPlayer[tokenId] = randomPlayerId();
        totalMints++;

        _safeMint(to, tokenId);
    }

    function randomPlayerId() private view returns (uint256) {
        uint randId = uint(keccak256(abi.encodePacked(totalMints)));
        return randId % maxPlayer; 
    }

    function getPlayerIdFromStickerId(uint256 stickerId) public view returns (uint256) {
        return stickerToPlayer[stickerId];
    }

    function getStickersFromWallet(address wallet) public view returns (uint256[] memory) {
        uint[] memory result = new uint[](balanceOf(wallet));
        uint counter = 0;

        for (uint i = 0; i < totalMints; i++){
            if (ownerOf(i) == wallet){
                result[counter] = i;
                counter++;
            }
        }

        return result;
    }
}