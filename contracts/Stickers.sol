//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract QatarSticker is ERC721 {
    uint256 public totalMints = 0;
    uint256 private maxPlayer = 600;
    address owner;
    uint256 public mintPrice = 1000000 gwei; 
    string public URI = "https://bafybeifqmgyfy4by3gpms5sdv3ft3knccmjsqxfqquuxemohtwfm7y7nwa.ipfs.dweb.link/metadata.json";

    // first-name
    // last-name
    // nationality
    // height
    // player-number
    // image

    mapping(address => uint256[]) public walletToStickers;  // address a id generado del NFT de la figurita
    mapping(uint256 => uint256) public stickerToPlayer;     // id del sticker al id del jugador
    mapping(uint256 => string) public playerToURI;          // id que representa al jdor a su URI

    constructor() ERC721("QatarSticker", "QST") {
        owner = msg.sender;
    }

    function safeMint(address to) internal {
        uint tokenId = totalMints;
        walletToStickers[msg.sender].push(tokenId);
        stickerToPlayer[tokenId] = randomPlayerId();
        totalMints++;

        _safeMint(to, tokenId);
    }

    function getStickersFromWallet(address wallet) public view returns (uint256[] memory) {
        return walletToStickers[wallet];
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
