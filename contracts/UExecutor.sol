// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./../CryptoPageLib/Admin.sol";
import "./../CryptoPageLib/ASafe.sol";
import "./../CryptoPageLib/interfaces/IStrategy.sol";

contract UExecutor is Admin, ASafe {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    // COUNTERS 
    Counters.Counter public _StrategyId;
    Counters.Counter public _totalStrategies;
    Counters.Counter public _activeStrategies;

    struct Strategy {
        uint256 id;
        address author;
        bool status;
    }
    mapping(string => Strategy) public _strategies;
    mapping(string => bool) private _keytank;

    /* INIT */
    constructor() Admin(msg.sender) {
        addSafe( msg.sender );
    }

    // CREATE NEW
    function createStrategy(string memory _key, address _account) public onlyOwner() {
        require(!_keytank[_key], "removeStrategy: _key doesn't exists");            
            _StrategyId.increment();
            _keytank[_key] = true;
            _strategies[_key] = Strategy({
                id: _StrategyId.current(),
                author: _account,
                status: true
            });
            _totalStrategies.increment();
            _activeStrategies.increment();
    }

    // UPDATE ADDRESS
    function updateStrategy(string memory _key, address _account) public onlyOwner() {
        require(_keytank[_key], "updateStrategy: _key doesn't exists");
        Strategy memory update = _strategies[_key];
        _strategies[_key] = Strategy({
                id: update.id,
                author: _account,
                status: update.status
        });
    }
    function pauseStrategy(string memory _key) public onlyOwner() {
        require(_keytank[_key], "pauseStrategy: _key doesn't exists");
        Strategy memory update = _strategies[_key];
        require(update.status, "pauseStrategy: _key doesn't exists");
        _strategies[_key] = Strategy({
                id: update.id,
                author: update.author,
                status: false
        });
    }
    function unpauseStrategy(string memory _key) public onlyOwner() {
        require(_keytank[_key], "unpauseStrategy: _key doesn't exists");
        Strategy memory update = _strategies[_key];
        require(!update.status, "unpauseStrategy: _key doesn't exists");
        _strategies[_key] = Strategy({
                id: update.id,
                author: update.author,
                status: true
        });
    }
    function removeStrategy(string memory _key) public onlyOwner() {
        require(_keytank[_key], "removeStrategy: _key doesn't exists");
        _keytank[_key] = false;
        delete _strategies[_key];
    }
    function getStrategy(string memory _key) public view  returns (
        uint256 id,
        address author,
        bool status) {
        require(_keytank[_key], "getStrategy: _key doesn't exists");
        Strategy memory strategy = _strategies[_key];
        id = strategy.id;
        author = strategy.author;
        status = strategy.status;
    }

    // INTERACTION
    function getJson(string memory _key, string memory _function, string memory _values) public view  returns (
        uint256 id,
        address author,
        bool status,
        string memory json) {
        require(_keytank[_key], "getStrategy: _key doesn't exists");
        Strategy memory xstrategy = _strategies[_key];
        id = xstrategy.id;
        author = xstrategy.author;
        status = xstrategy.status;

        require(status, "strategy on pause");
        IStrategy _mycontract = IStrategy(author);
        json = _mycontract.getJson(_function,_values);
        // string memory _function
        // string memory _values
    }

    /**
    // INTERACTION
    function runUE(string memory _key, string memory _function, string memory _values) public {
        require(_keytank[_key], "getStrategy: _key doesn't exists");
        Strategy memory xstrategy = _strategies[_key];
        id = xstrategy.id;
        author = xstrategy.author;
        status = xstrategy.status;

        require(status, "strategy on pause");
        IUE _mycontract = IUE(author);
        json = _mycontract.getJson(_function,_values);
        // string memory _function, string memory _values
    }
    */

    // TODO library of values
    // key - string name
    // type - address / int / string / json

    // TODO json like value

    // TODO use init function when start if constructor do not work
    /*
    bool private is_init = false;
    function init() public onlyOwner() {
        
    }
    */
}

