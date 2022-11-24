//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Stickers.sol";

/// @title 
/// @author @mrti259/@saantim/@ovr4ulin
/// @notice 
/// @dev 
contract ExchangeOfQatarSticker is QatarSticker{
    struct exchange {
        address owner;
        uint tokenIdToExchange;
        uint playerIdWanted;
        bool active;
    }

    mapping(uint256 => exchange) public exchanges;
    uint public numberOfExchanges = 0;    

    /// @dev This modifier verifies if the exchange is valid
    /// @param exchangeId It's the unique-number of the exchange to verify
    modifier exchageExist(uint exchangeId){
        require(exchangeId <= numberOfExchanges, "exchangeId doesn't exists");
        _;
    }

    /// @dev This modifier verifies if the msg.sender is the owner of the sticker.
    /// @param stickerId It's the unique-number of the NFT Sticker to verify
    modifier onlyOwnerOfSticker(uint stickerId){
        require(ownerOf(stickerId) == msg.sender, "message sender is not sticker owner");
        _;
    }

    /// @dev This modifier verifies if the msg.sender is the owner of the exchange.
    /// @param exchangeId It's the unique-number of the exchange to verify
    modifier onlyOwnerOfExchange(uint exchangeId){
        require(exchanges[exchangeId].owner == msg.sender, "message sender is not exchange owner");
        _;
    }

    /// @dev This modifier verifies if the exchange is active
    /// @param exchangeId It's the unique-number of the exchange to verify
    modifier isActive(uint exchangeId){
        require(exchanges[exchangeId].active, "exchange is not active");
        _;
    }

    /// @notice You can use this function to initialize an exchange
    /// @dev 
    /// @param tokenId It's the token to exchange
    /// @param playerId It's the playerId wanted
    function iWantToExchange(uint tokenId, uint playerId) public onlyOwnerOfSticker(tokenId) {
        exchanges[numberOfExchanges] = exchange(msg.sender, tokenId, playerId, true);
        numberOfExchanges++;
    }

    /// @notice You can use this function to accept an exchange 
    /// @dev If the exchanges exists and is an active exchange this function will verify if the message sender could accept it, and in that case, this function will execute the exchange of the sticker using the sticker transfer method 
    /// @param exchangeId It's the unique-number of the exchange to be accepted
    function acceptExchange(uint exchangeId) public exchageExist(exchangeId) isActive(exchangeId){
        exchange memory e = exchanges[exchangeId];
        uint playerIdWanted = e.playerIdWanted;
        uint tokenIdToExchange = e.tokenIdToExchange;
        address owner = e.owner;
        address interested = msg.sender;

        (bool wantedPlayer, uint tokenIdWanted) = hasWantedPlayer(playerIdWanted, interested);
        require(wantedPlayer, "The person who is accepting exchange hasn't wanted player");

        _transfer(owner, interested, tokenIdToExchange);
        _transfer(interested, owner, tokenIdWanted);
        cancelExchangeWithExchangeId(tokenIdToExchange);
        cancelExchangeWithExchangeId(tokenIdWanted);
    }

    /// @dev You can use this function to cancel an Exchange. After that, the exchange can not be accepted
    /// @param tokenId It's the unique-number of the exchange to be canceled
    function cancelExchangeWithExchangeId(uint tokenId) private {
        for (uint i = 0; i <= numberOfExchanges; i++){
            if (exchanges[i].active == true && exchanges[i].tokenIdToExchange == tokenId){
                exchanges[i].active = false;
            }
        }
    }

    /// @notice You can cancel an exchange
    /// @dev Changes the active status of an exchange to false
    /// @param exchangeId It's the unique-number of the exchange to cancel
    function cancelExchange(uint exchangeId) public exchageExist(exchangeId) onlyOwnerOfExchange(exchangeId){
        exchanges[exchangeId].active = false;
    }

    /// @notice Shows the active exchanges
    /// @dev Count by the exchanges mapping all the active exchanges and returns the quantity number of active exchanges
    /// @return quantity It's the amount of actives exchanges
    function activeExchanges() public view returns(uint) {
        uint counter = 0;

        for (uint i = 0; i <= numberOfExchanges; i++){
            if (exchanges[i].active == true){
                counter++;
            }
        }
        return counter;
    }

    /// @notice You can use this function to get an array of all exchanges' Ids
    /// @dev This function returns only active exchanges
    /// @return array It's an array with all exchanges' Ids
    function getAllExchanges() public view returns(uint[] memory) {
        uint counter = 0;
        uint[] memory result = new uint[](activeExchanges());

        for (uint i = 0; i < numberOfExchanges; i++){
            if (exchanges[i].active == true){
                result[counter] = i;
                counter++;
            }
        }

        return result;
    }

    /// @dev Verify if a wallet have a specify playerId into his stickers. Search this playerId calling getPlayerIdFromStickerId function through all his stickers
    /// @param playerIdWanted It's the searched playerId 
    /// @param wallet It's the address where the playerId gonna be looked by
    /// @return result A positive or negative expression of the search result
    /// @return stickerId If could find the wanted player it returns the stickerId, otherwise returns 0
    function hasWantedPlayer(uint playerIdWanted, address wallet) internal view returns (bool, uint) {
        uint256[] memory stickers = getStickersFromWallet(wallet);

        for (uint i = 0; i < stickers.length; i++){
            if (getPlayerIdFromStickerId(stickers[i]) == playerIdWanted){
                return (true, stickers[i]);
            }
        }
        return (false, 0);
    }
}