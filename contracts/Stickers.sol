//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @title A world cup sticker implementation
/// @author @mrti259/@saantim/@ovr4ulin
/// @notice You can use this contract to generate NFT stickers
/// @dev This contract can mint a pseudo-random sticker using the ERC721 interface
contract QatarSticker is ERC721, Ownable{

    uint256 public totalMints = 0;
    uint256 public mintPrice = 1000000 gwei; 
    string private URI = "";
    
    mapping(uint256 => uint256) public stickerToPlayer;
    
    address private packageContractAddress;
    uint256 private maxPlayer = 711;

    /// @notice You can set the package contract where you gonna get your stickers from
    /// @dev From here you can set the package contract. This contract gonna be necesary to use the onlyPackageContract() modifier
    /// @param newPackageContractAddress a package contract address
    function setPackageContractAddress(address newPackageContractAddress) public onlyOwner {
        packageContractAddress = newPackageContractAddress;
    }

    /// @dev This modifier verifies if the package contract is the message sender
    modifier onlyPackageContract(){
        require(msg.sender == packageContractAddress);
        _;
    }

    constructor() ERC721("QatarSticker", "QST") {
    }

    /// @notice You can use this function to mint Stickers 
    /// @dev This function can be called only for PackageContract
    /// @param packageOwner It's the owner of the stickers
    /// @param quantity It's the number of stickers to be minted
    function createStickers(address packageOwner, uint256 quantity) public onlyPackageContract {
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
        uint randId = uint(keccak256(abi.encodePacked(totalMints + block.timestamp)));
        return randId % maxPlayer; 
    }

    /// @notice You can use this function to know sticker's player
    /// @dev A mapping index-access to get the playerId by his stickerId
    /// @param stickerId This function returns the player associated with this stickerId
    /// @return playerId It's the unique-number of the player associated to the stickerId
    function getPlayerIdFromStickerId(uint256 stickerId) public view returns (uint256) {
        return stickerToPlayer[stickerId];
    }
    
    /// @notice You can get a list of all sticker associated to a wallet
    /// @dev This function go through all the minted tokens and push into a list each token associated to a specify wallet
    /// @param wallet This function will search all the associated tokens to this address
    /// @return stickers Returns a collection of all the associated tokens to the wallet used as parameter
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

    /// @dev If <s1> and <s2> are equal, so the function returns True, else it returns False.
    /// @param s1 It's first string to compare.
    /// @param s2 It's second string to compare.
    /// @return areEquals It's True if <s1> and <s2> are equals, else it's False.
    function stringsEquals(string memory s1, string memory s2) private pure returns (bool) {
        bytes memory b1 = bytes(s1);
        bytes memory b2 = bytes(s2);
        uint256 l1 = b1.length;
        if (l1 != b2.length) return false;
        for (uint256 i=0; i<l1; i++) {
            if (b1[i] != b2[i]) return false;
        }
        return true;
    }

    /// @dev This modifier verifies if the URI base was set
    modifier withURISetted() {
        require(!stringsEquals(URI, ""));
        _;
    }

    function _baseURI(string memory newURI) internal virtual {
        URI = newURI;
    }

    /// @notice You can use this function to set URI base.
    /// @dev This function only can be called by contract's owner.
    /// @param newURI URI to set.
    function setURIBase(string memory newURI) public onlyOwner {
        _baseURI(newURI);
    }

    /// @notice You can use this function to get sticker URI.
    /// @return URI It's the URI of stickerId.
    function tokenURI(uint256 stickerId) public view virtual override withURISetted returns (string memory) {
        _requireMinted(stickerId);
        uint256 playerId = getPlayerIdFromStickerId(stickerId);
        string memory playerIdStr = Strings.toString(playerId);
        return string.concat(URI, playerIdStr);
    }
}