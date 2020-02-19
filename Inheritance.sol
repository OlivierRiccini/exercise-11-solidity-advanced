pragma solidity ^0.6.1;

contract SafeMath {
    function add(int256 _a, int256 _b) internal pure returns (int256) {
        int256 res = _a + _b;
        require(res >= _a, 'Overflow');
        return res;
    }
   
    function subtract(int256 _a, int256 _b) internal pure returns (int256) {
        require(_b <= _a, 'Underflow');
        return _a - _b;
    }
   
    function multiply(int256 _a, int256 _b) internal pure returns (int256) {
        int256 res = _a * _b;
        require(res / _a == _b, "Multiplication overflow");
        return res;
    }
}

contract Owned is SafeMath {
    address owner;
   
    modifier onlyOwner() {
        require(msg.sender == owner, 'Only owner can perform this action');
        _;
    }
   
    constructor() public {
        owner = msg.sender;
    }
   
    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}

contract Inheritance is Owned {
    int256 stateInterger;
    uint private lastTimeStateChanged;
    event StateChanged(int256 stateInterger);
   
    function changeState() public onlyOwner {
        stateInterger = add(stateInterger, int256(now % 266));
        stateInterger = multiply(stateInterger, int256((now - lastTimeStateChanged)));
        stateInterger = stateInterger - int256(block.gaslimit);
        lastTimeStateChanged = now;
        emit StateChanged(stateInterger);
    }
}