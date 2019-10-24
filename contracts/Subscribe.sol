pragma solidity ^0.4.24;

import "@aragon/os/contracts/apps/AragonApp.sol";
import "@aragon/os/contracts/common/IForwarder.sol";
import "@aragon/os/contracts/lib/math/SafeMath64.sol";
import "@aragon/apps-token-manager/contracts/TokenManager.sol";

contract Subscribe is IForwarder, AragonApp {
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
    /* bytes32 constant public SUBSCRIBE_ROLE = keccak256("SUBSCRIBE_ROLE"); */
    bytes32 constant public SET_PRICE_ROLE = keccak256("SET_PRICE_ROLE");
    bytes32 constant public SET_DURATION_ROLE = keccak256("SET_DURATION_ROLE");

    string private constant ERROR_PERMISSION = "PERMISSION";

    function initialize(TokenManager _tokenManager, uint _price, uint64 _duration) onlyInit public {
        initialized();
        tokenManager = _tokenManager;
        price = _price;
        duration = _duration;
    }

    /* function subscribe(address _subscriber, uint16 _units) authP(SUBSCRIBE_ROLE, arr(_subscriber)) public { */
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

    /**
    * @notice Execute action based on active subscription
    * @dev IForwarder interface conformance
    * @param _evmScript Start proposal with script
    */
    function forward(bytes _evmScript) public {
        require(canForward(msg.sender, _evmScript), ERROR_PERMISSION);

        // Add the tokenManager to the blacklist to disallow a subscriber from
        // executing MINT/BURN on this contract's behalf
        address[] memory blacklist = new address[](1);
        blacklist[0] = address(tokenManager);

        runScript(_evmScript, new bytes(0), blacklist);
    }

    function canForward(address _sender, bytes) public view returns (bool) {
        return expirations[_sender] > uint64(now);
    }

    function isForwarder() public pure returns (bool) {
        return true;
    }
}
