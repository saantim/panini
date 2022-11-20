//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Stickers.sol";

contract ExchangeOfQatarSticker is QatarSticker{
    // ---------------------------------------------------
    // structs
    // ---------------------------------------------------
    struct exchange {
        uint exchangeId;
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
        require(exchangeId < numberOfExchanges);
        _;
    }

    modifier onlyOwnerOfSticker(uint stickerId){
        require(ownerOf(stickerId) == msg.sender);
        _;
    }

    modifier onlyOwnerOfExchange(uint exchangeId){
        require(exchanges[exchangeId].owner == msg.sender);
        _;
    }

    modifier isActive(uint exchangeId){
        require(exchanges[exchangeId].active);
        _;
    }

    // ---------------------------------------------------
    // functions
    // ---------------------------------------------------
    function iWantToExchange(uint tokenId, uint playerId) public onlyOwnerOfSticker(tokenId) {
        numberOfExchanges++;
        exchanges[numberOfExchanges] = exchange(numberOfExchanges, msg.sender, tokenId, playerId, true);
    }

    function acceptExchange(uint exchangeId) public exchageExist(exchangeId) isActive(exchangeId){
        exchange memory e = exchanges[exchangeId];
        uint playerIdWanted = e.playerIdWanted;
        uint tokenIdToExchange = e.tokenIdToExchange;
        address owner = e.owner;
        address interested = msg.sender;

        (bool hasWantedPlayer, uint tokenIdWanted) = heHasWantedPlayer(playerIdWanted, interested);
        require(hasWantedPlayer);

        _transfer(owner, interested, tokenIdToExchange);
        _transfer(interested, owner, tokenIdWanted);
    }

    function cancelExchange(uint exchangeId) public exchageExist(exchangeId) onlyOwnerOfExchange(exchangeId){
        exchanges[exchangeId].active = false;
    }

    function getAllExchanges() public view returns(uint[] memory) {
        uint[] memory result = new uint[](numberOfExchanges);

        uint counter = 0;

        for (uint i = 0; i < numberOfExchanges; i++){
            if (exchanges[i].active == true){
                result[counter] = i;
                counter++;
            }
        }

        return result;
    }

    function heHasWantedPlayer(uint playerIdWanted, address wallet) internal view returns (bool, uint) {
        uint256[] memory stickers = getStickersFromWallet(wallet);

        for (uint i = 0; i < stickers.length; i++){
            if (getPlayerIdFromStickerId(stickers[i]) == playerIdWanted){
                return (true, stickers[i]);
            }
        }
        return (false, 0);
    }
}