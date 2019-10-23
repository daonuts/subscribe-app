pragma solidity ^0.4.24;

import "@aragon/os/contracts/apps/AragonApp.sol";
import "@aragon/apps-token-manager/contracts/TokenManager.sol";
import "@aragon/os/contracts/lib/math/SafeMath64.sol";

contract Subscribe is AragonApp {
    using SafeMath64 for uint64;

    /// Events
    event Subscribe(address indexed subscriber, address purchaser, uint64 expiration);
    event PriceChange(uint price);
    event DurationChange(uint duration);

    uint public price;
    uint64 public duration;
    TokenManager public tokenManager;
    mapping(address => uint64) public expirations;

    /// ACL
    bytes32 constant public SET_PRICE_ROLE = keccak256("SET_PRICE_ROLE");
    bytes32 constant public SET_DURATION_ROLE = keccak256("SET_DURATION_ROLE");

    function initialize(TokenManager _tokenManager, uint _price, uint64 _duration) onlyInit public {
        initialized();
        tokenManager = _tokenManager;
        price = _price;
        duration = _duration;
    }

    function subscribe(address _subscriber, uint16 _units) public {
        tokenManager.burn(msg.sender, _units*price);
        uint64 start = uint64(now);
        if(expirations[_subscriber] > start)
            start = expirations[_subscriber];
        expirations[_subscriber] = start.add(uint64(_units).mul(duration));
        emit Subscribe(_subscriber, msg.sender, expirations[_subscriber]);
    }

    function setPrice(uint _price) auth(SET_PRICE_ROLE) public {
        price = _price;
        emit PriceChange(price);
    }

    function setDuration(uint64 _duration) auth(SET_DURATION_ROLE) public {
        duration = _duration;
        emit DurationChange(duration);
    }
}
