pragma solidity ^0.6.1;

contract Bank {
    address owner;
    mapping(address => uint) private balanceOf;
   
    enum MathOperation { Addition, Substraction }

    event NewDeposit(address _user, uint _amount, uint _newBalance);
    event NewWithdraw(address _user, uint _amount, uint _newBalance);
   
    constructor() public {
        owner = msg.sender;
    }
   
    modifier overflowCheck(MathOperation _operation, uint _amount) {
        if (_operation == MathOperation.Addition) {
            require(balanceOf[msg.sender] + _amount >= balanceOf[msg.sender], 'Overflow');
        }
        if (_operation == MathOperation.Substraction) {
            require(_amount <= balanceOf[msg.sender], 'Underflow');
        }
        _;
    }
   
    function deposit(uint256 _amount) public payable overflowCheck(MathOperation.Addition, _amount) returns (uint) {
        require(msg.value == _amount, 'Amount value must be the same in message value as in _amount parameter');
        balanceOf[msg.sender] += _amount;
        emit NewDeposit(msg.sender, _amount, balanceOf[msg.sender]);
        return balanceOf[msg.sender];
    }
   
    function withdraw(uint _amount) public overflowCheck(MathOperation.Substraction, _amount) returns (uint) {
        balanceOf[msg.sender] -= _amount;
        msg.sender.transfer(_amount);
        emit NewWithdraw(msg.sender, _amount, balanceOf[msg.sender]);
        return balanceOf[msg.sender];
    }
   
    function getBalance() public view returns (uint) {
        return balanceOf[msg.sender];
    }
   
}