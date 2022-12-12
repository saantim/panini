//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title A world cup sticker implementation
/// @author @mrti259/@saantim/@ovr4ulin
/// @notice You can use this contract to generate NFT stickers
/// @dev This contract can mint a pseudo-random sticker using the ERC721 interface
contract QatanSticker is ERC721, Ownable {
    uint256 public totalMints = 0;
    string public URI =
        "https://bafybeifqmgyfy4by3gpms5sdv3ft3knccmjsqxfqquuxemohtwfm7y7nwa.ipfs.dweb.link/metadata.json";

    mapping(uint256 => uint256) public stickerToPlayer;
    mapping(uint256 => string) public playerToURI;

    uint256 private maxPlayer = 711;

    constructor() ERC721("QatarSticker", "QST") {}

    /// @notice You can use this function to mint Stickers
    /// @dev This function can be called only for PackageContract
    /// @param packageOwner It's the owner of the stickers
    /// @param quantity It's the number of stickers to be minted
    function createStickers(
        address packageOwner,
        uint256 quantity
    ) internal {
        for (uint i = 0; i < quantity; i++) {
            safeMint(packageOwner);
        }
    }

    /// @dev This internal function generates a pseudo-random playerId and mint the associated token
    /// @param to This address gonna be the owner of the minted token
    function safeMint(address to) internal {
        uint tokenId = totalMints;
        stickerToPlayer[tokenId] = randomPlayerId();
        totalMints++;

        _safeMint(to, tokenId);
    }

    /// @dev This private function returns a pseudo random value less than `maxPlayer`
    /// @return randomPlayerId It's a pseudo random value less than `maxPlayer`
    function randomPlayerId() private view returns (uint256) {
        uint randId = uint(keccak256(abi.encodePacked(totalMints)));
        return randId % maxPlayer;
    }

    /// @notice You can use this function to know sticker's player
    /// @dev A mapping index-access to get the playerId by his stickerId
    /// @param stickerId This function returns the player associated with this stickerId
    /// @return playerId It's the unique-number of the player associated to the stickerId
    function getPlayerIdFromStickerId(
        uint256 stickerId
    ) public view returns (uint256) {
        return stickerToPlayer[stickerId];
    }

    /// @notice You can get a list of all sticker associated to a wallet
    /// @dev This function go through all the minted tokens and push into a list each token associated to a specify wallet
    /// @param wallet This function will search all the associated tokens to this address
    /// @return stickers Returns a collection of all the associated tokens to the wallet used as parameter
    function getStickersFromWallet(
        address wallet
    ) public view returns (uint256[] memory) {
        uint[] memory result = new uint[](balanceOf(wallet));
        uint counter = 0;

        for (uint i = 0; i < totalMints; i++) {
            if (ownerOf(i) == wallet) {
                result[counter] = i;
                counter++;
            }
        }

        return result;
    }
}
