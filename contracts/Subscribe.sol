pragma solidity ^0.4.24;

import "@aragon/os/contracts/apps/AragonApp.sol";
import "@aragon/apps-token-manager/contracts/TokenManager.sol";

contract Subscribe is AragonApp {

    /// Events
    event Subscribe(address indexed subscriber, address purchaser, uint start, uint duration);
    event PriceChange(uint price);
    event DurationChange(uint duration);

    uint public price;
    uint public duration;
    TokenManager public tokenManager;

    /// ACL
    bytes32 constant public SET_PRICE_ROLE = keccak256("SET_PRICE_ROLE");
    bytes32 constant public SET_DURATION_ROLE = keccak256("SET_DURATION_ROLE");

    function initialize(TokenManager _tokenManager, uint _price, uint _duration) onlyInit public {
        initialized();
        tokenManager = _tokenManager;
        price = _price;
        duration = _duration;
    }

    function subscribe(address _subscriber, uint16 _units) public {
        tokenManager.burn(msg.sender, _units*price);
        emit Subscribe(_subscriber, msg.sender, block.timestamp, _units*duration);
    }

    function setPrice(uint _price) auth(SET_PRICE_ROLE) public {
        price = _price;
        emit PriceChange(price);
    }

    function setDuration(uint _duration) auth(SET_DURATION_ROLE) public {
        duration = _duration;
        emit DurationChange(duration);
    }
}
