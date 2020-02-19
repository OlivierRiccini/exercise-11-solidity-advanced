pragma solidity >=0.4.22;

contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract LemonToken is ERC20Basic {
    string public name;
    string public symbol;
    uint public decimals;
    uint256 public initialSupply;
    uint256 public totalSupply_;
   
    mapping (address => uint) private contributors;
   
    constructor() public {
        name = "LemonToken";
        symbol = "LMN";
        decimals = 18;
        initialSupply = 1000000;
        totalSupply_ = initialSupply;
        contributors[msg.sender] = initialSupply;
    }
   
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }
   
    function balanceOf(address _who) public view returns (uint256) {
        return contributors[_who];
    }
   
    function transfer(address _to, uint256 _value) public returns (bool) {
       bool _overflow = contributors[_to] + _value < contributors[_to];
       bool _underflow = _value > contributors[msg.sender];
        if (!_overflow && !_underflow && contributors[msg.sender] >= _value && _value > 0) {
            contributors[msg.sender] -= _value;
            contributors[_to] += _value;
            totalSupply_ -= _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }
}

contract LemonCrowdsale {
    uint public startTime;
    uint public endTime;
    uint public rateOfTokensToGivePerEth;
    address walletToStoreTheEthers;
    LemonToken public lemonToken;
    mapping (address => uint) public contribution;
   
    constructor(uint _rate) public {
        startTime = now;
        endTime = now + 24 hours;
        walletToStoreTheEthers = msg.sender;
        // Conversion rate from ETH to Token
        rateOfTokensToGivePerEth = _rate;
       
        lemonToken = new LemonToken();
    }
   
    event TokenSold(address _contributor, uint _tokens);
   
    modifier durationCheck() {
        require(!hasEnded(), 'Crowdsale has ended!');
        _;
    }
   
    function buyTokens() public payable durationCheck {
        uint tokens = rateOfTokensToGivePerEth * (msg.value / 1 ether);
       require(tokens > 0, 'You are not allow to buy 0 tokens');
       walletToStoreTheEthers.transfer(msg.value);
       lemonToken.transfer(msg.sender, tokens);
       contribution[msg.sender] += tokens;
       emit TokenSold(msg.sender, tokens);
    }
   
    function hasEnded() public view returns (bool) {
        return endTime <= now;
    }
}