pragma solidity ^0.4.24;

import "@aragon/os/contracts/apps/AragonApp.sol";
import "@aragon/apps-token-manager/contracts/TokenManager.sol";

contract Subscription is AragonApp {

    /// Events
    event Subscribe(address indexed subscriber, uint16 units);

    uint public unitPrice;
    uint public unitTime;
    TokenManager public tokenManager;

    /// ACL
    bytes32 constant public SET_PRICE_ROLE = keccak256("SET_PRICE_ROLE");
    bytes32 constant public SET_TIME_ROLE = keccak256("SET_TIME_ROLE");

    function initialize(TokenManager _tokenManager, uint _unitPrice, uint _unitTime) onlyInit public {
        initialized();
        tokenManager = _tokenManager;
        unitPrice = _unitPrice;
        unitTime = _unitTime;
    }

    function subscribe(address _subscriber, uint16 _units) public {
        tokenManager.burn(msg.sender, _units*unitPrice);
        emit Subscribe(_subscriber, _units);
    }

    function setUnitPrice(uint _unitPrice) auth(SET_PRICE_ROLE) public {
        unitPrice = _unitPrice;
    }

    function setUnitTime(uint _unitTime) auth(SET_TIME_ROLE) public {
        unitTime = _unitTime;
    }
}
