pragma solidity ^0.6.1;

contract Deposit {
    address owner;
   
    event NewDeposit(address _sender, uint _amount);

    modifier onlyOwner() {
        require(msg.sender == owner, 'Only owner can perfom this action');
        _;
    }
   
    constructor() public {
        owner = msg.sender;
    }
   
    function deposit(uint256 _amount) public payable {
        require(msg.value == _amount, 'Amount value must be the same in message value as in _amount parameter');
        emit NewDeposit(msg.sender, _amount);
    }
   
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
   
    function send(address payable  _payee) public onlyOwner {
        selfdestruct(_payee);
    }

}