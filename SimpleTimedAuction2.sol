pragma solidity ^0.6.1;

contract SimpleTimedAuction {
    address owner;
    uint tokenAmountToSell;
    uint startingBlock;
    uint endingBlock;
    mapping(address => uint) private buyers;
    
    event NewSale(address _buyer, uint _quantity, uint _tokensRemaining);
    
    constructor(uint _tokenAmountToSell) public {
        owner = msg.sender;
        tokenAmountToSell = _tokenAmountToSell;
        startingBlock = block.number;
        endingBlock = startingBlock + 1;
    }
    
    modifier onlyBefore() {
        require(block.number <= endingBlock, 'You cannot buy tokens anymore');
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