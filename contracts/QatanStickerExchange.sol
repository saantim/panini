//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./QatanStickerPackage.sol";

/// @title A Sticker Exchange's implementation
/// @author @mrti259/@saantim/@ovr4ulin
/// @notice You can use this contract to swap stickers between differt wallets
/// @dev You can create an exchange where you offer one sticker token and requier another one. Then another person could accept this exchange if meet the requierments.
contract QatanStickerExchange is QatanStickerPackage {
    struct Exchange {
        address owner;
        uint256 tokenIdToExchange;
        uint256 playerIdWanted;
        bool active;
    }

    mapping(uint256 => Exchange) public exchanges;
    uint256 public numberOfExchanges = 0;

    /// @dev This modifier verifies if the exchange is valid
    /// @param exchangeId It's the unique-number of the exchange to verify
    modifier exchageExist(uint256 exchangeId) {
        require(exchangeId <= numberOfExchanges, "exchangeId doesn't exists");
        _;
    }

    /// @dev This modifier verifies if the msg.sender is the owner of the sticker.
    /// @param stickerId It's the unique-number of the NFT Sticker to verify
    modifier onlyOwnerOfSticker(uint256 stickerId) {
        require(
            ownerOf(stickerId) == msg.sender,
            "message sender is not sticker owner"
        );
        _;
    }

    /// @dev This modifier verifies if the msg.sender is the owner of the exchange.
    /// @param exchangeId It's the unique-number of the exchange to verify
    modifier onlyOwnerOfExchange(uint256 exchangeId) {
        require(
            exchanges[exchangeId].owner == msg.sender,
            "message sender is not exchange owner"
        );
        _;
    }

    /// @dev This modifier verifies if the exchange is active
    /// @param exchangeId It's the unique-number of the exchange to verify
    modifier isActive(uint256 exchangeId) {
        require(exchanges[exchangeId].active, "exchange is not active");
        _;
    }

    /// @notice You can use this function to create an exchange
    /// @dev Add to the exchange mapping a new exchange
    /// @param tokenId It's the token to exchange
    /// @param playerId It's the playerId wanted
    function createExchange(
        uint256 tokenId,
        uint256 playerId
    ) public onlyOwnerOfSticker(tokenId) {
        exchanges[numberOfExchanges] = Exchange(
            msg.sender,
            tokenId,
            playerId,
            true
        );
        numberOfExchanges++;
    }

    /// @notice You can use this function to accept an exchange
    /// @dev If the exchanges exists and is an active exchange this function will verify if the message sender could accept it, and in that case, this function will execute the exchange of the sticker using the sticker transfer method
    /// @param exchangeId It's the unique-number of the exchange to be accepted
    function acceptExchange(
        uint256 exchangeId
    ) public exchageExist(exchangeId) isActive(exchangeId) {
        Exchange memory e = exchanges[exchangeId];
        uint256 playerIdWanted = e.playerIdWanted;
        uint256 tokenIdToExchange = e.tokenIdToExchange;
        address owner = e.owner;
        address interested = msg.sender;

        uint256 tokenIdWanted = getPlayerFromWallet(playerIdWanted, interested);
        require(tokenIdWanted == 0, "Player is missing");

        _transfer(owner, interested, tokenIdToExchange);
        _transfer(interested, owner, tokenIdWanted);
        cancelExchangeWithTokenId(tokenIdToExchange);
        cancelExchangeWithTokenId(tokenIdWanted);
    }

    /// @dev You can use this function to cancel an Exchange. After that, the exchange can not be accepted
    /// @param tokenId It's the unique-number of the exchange to be canceled
    function cancelExchangeWithTokenId(uint256 tokenId) private {
        for (uint256 i = 0; i <= numberOfExchanges; i++) {
            if (
                exchanges[i].active == true &&
                exchanges[i].tokenIdToExchange == tokenId
            ) {
                exchanges[i].active = false;
            }
        }
    }

    /// @notice You can cancel an exchange
    /// @dev Changes the active status of an exchange to false
    /// @param exchangeId It's the unique-number of the exchange to cancel
    function cancelExchange(
        uint256 exchangeId
    ) public exchageExist(exchangeId) onlyOwnerOfExchange(exchangeId) {
        exchanges[exchangeId].active = false;
    }

    /// @notice Shows the active exchanges
    /// @dev Count by the exchanges mapping all the active exchanges and returns the quantity number of active exchanges
    /// @return quantity It's the amount of actives exchanges
    function activeExchanges() public view returns (uint256) {
        uint256 counter = 0;

        for (uint256 i = 0; i <= numberOfExchanges; i++) {
            if (exchanges[i].active == true) {
                counter++;
            }
        }
        return counter;
    }

    /// @notice You can use this function to get an array of all exchanges' Ids
    /// @dev This function returns only active exchanges
    /// @return array It's an array with all exchanges' Ids
    function getAllExchanges() public view returns (uint256[] memory) {
        uint256 counter = 0;
        uint256[] memory result = new uint256[](activeExchanges());

        for (uint256 i = 0; i < numberOfExchanges; i++) {
            if (exchanges[i].active == true) {
                result[counter] = i;
                counter++;
            }
        }

        return result;
    }

    /// @notice Get a tokenId for playerIdWanter from wallet
    /// @param playerIdWanted It's the searched playerId
    /// @param wallet It's the address where the playerId gonna be looked by
    /// @return stickerId If could find the wanted player it returns the stickerId, otherwise returns 0
    function getPlayerFromWallet(
        uint256 playerIdWanted,
        address wallet
    ) internal view returns (uint256) {
        uint256[] memory stickers = getStickersFromWallet(wallet);

        for (uint256 i = 0; i < stickers.length; i++) {
            if (getPlayerIdFromStickerId(stickers[i]) == playerIdWanted) {
                return stickers[i];
            }
        }
        return 0;
    }
}
