pragma solidity ^0.6.1;

contract SimpleTimedAuction {
    address owner;
    uint tokenAmountToSell;
    uint startTime;
    uint durationTime;
    mapping(address => uint) private buyers;
    
    event NewSale(address _buyer, uint _quantity, uint _tokensRemaining);
    
    constructor(uint _tokenAmountToSell) public {
        owner = msg.sender;
        tokenAmountToSell = _tokenAmountToSell;
        startTime = now;
        durationTime = 60 seconds;
    }
    
    modifier onlyBefore() {
        require(now < startTime + durationTime, 'You cannot buy tokens anymore');
        _;
    }
    
    function buyTokens(uint _amount) public onlyBefore {
        require(_amount > 0, 'You cannot buy 0 tokens');
        require(tokenAmountToSell >= _amount, 'Not enough tokens remaining');
        require(buyers[msg.sender] + _amount >= buyers[msg.sender], 'Overflow');
        tokenAmountToSell -= _amount;
        buyers[msg.sender] += _amount;
        emit NewSale(msg.sender, _amount, tokenAmountToSell);
    }
    
}