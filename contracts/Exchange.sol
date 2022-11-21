//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Stickers.sol";

contract ExchangeOfQatarSticker is QatarSticker{
    // ---------------------------------------------------
    // structs
    // ---------------------------------------------------
    struct exchange {
        address owner;
        uint tokenIdToExchange;
        uint playerIdWanted;
        bool active;
    }

    // ---------------------------------------------------
    // public variables
    // ---------------------------------------------------
    mapping(uint256 => exchange) public exchanges;
    uint public numberOfExchanges = 0;    

    // ---------------------------------------------------
    // modifiers
    // ---------------------------------------------------
    modifier exchageExist(uint exchangeId){
        require(exchangeId <= numberOfExchanges, "exchangeId doesn't exists");
        _;
    }

    modifier onlyOwnerOfSticker(uint stickerId){
        require(ownerOf(stickerId) == msg.sender, "message sender is not sticker owner");
        _;
    }

    modifier onlyOwnerOfExchange(uint exchangeId){
        require(exchanges[exchangeId].owner == msg.sender, "message sender is not exchange owner");
        _;
    }

    modifier isActive(uint exchangeId){
        require(exchanges[exchangeId].active, "exchange is not active");
        _;
    }

    // ---------------------------------------------------
    // functions
    // ---------------------------------------------------
    function iWantToExchange(uint tokenId, uint playerId) public onlyOwnerOfSticker(tokenId) {
        exchanges[numberOfExchanges] = exchange(msg.sender, tokenId, playerId, true);
        numberOfExchanges++;
    }

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
        cancelExchangeWithTokenId(tokenIdToExchange);
        cancelExchangeWithTokenId(tokenIdWanted);
    }

    function cancelExchangeWithTokenId(uint tokenId) private {
        for (uint i = 0; i <= numberOfExchanges; i++){
            if (exchanges[i].active == true && exchanges[i].tokenIdToExchange == tokenId){
                exchanges[i].active = false;
            }
        }
    }

    function cancelExchange(uint exchangeId) public exchageExist(exchangeId) onlyOwnerOfExchange(exchangeId){
        exchanges[exchangeId].active = false;
    }

    function activeExchanges() public view returns(uint) {
        uint counter = 0;

        for (uint i = 0; i <= numberOfExchanges; i++){
            if (exchanges[i].active == true){
                counter++;
            }
        }
        return counter;
    }

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