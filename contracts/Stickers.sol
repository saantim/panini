//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract QatarSticker is ERC721 {
    uint256 public totalMints = 0;
    uint256 private maxPlayer = 711;
    address owner;
    uint256 public mintPrice = 1000000 gwei; 
    string public URI = "https://bafybeifqmgyfy4by3gpms5sdv3ft3knccmjsqxfqquuxemohtwfm7y7nwa.ipfs.dweb.link/metadata.json";

    mapping(uint256 => uint256) public stickerToPlayer;
    mapping(uint256 => string) public playerToURI; 

    constructor() ERC721("QatarSticker", "QST") {
        owner = msg.sender;
    }

    function safeMint(address to) internal {
        uint tokenId = totalMints;
        stickerToPlayer[tokenId] = randomPlayerId();
        totalMints++;

        _safeMint(to, tokenId);
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

    function getPlayerIdFromStickerId(uint256 stickerId) public view returns (uint256) {
        return stickerToPlayer[stickerId];
    }

    function mintToken(uint256 quantity_) public payable {
        require(quantity_ * mintPrice == msg.value, "wrong amount sent");

        for (uint i; i < quantity_; i++) {
            safeMint(msg.sender);
        }
    }

    function randomPlayerId() private view returns (uint256) {
        uint randId = uint(keccak256(abi.encodePacked(block.timestamp)));
        return randId % maxPlayer; 
    }

    function withdraw() public {
        payable(owner).transfer(address(this).balance);
    }
}