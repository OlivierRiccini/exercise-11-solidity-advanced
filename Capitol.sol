pragma solidity ^0.6.1;
pragma experimental ABIEncoderV2;

contract Capitol {
    string constant Female = 'female';
    string constant Male = 'male';
    uint startDate;
    uint endDate;
    uint durationTime;
    bool hasStarted = false;
    bool finalResult;
    bool isFinalResultDefined = false;
    
     struct Person {
        string gender;
        uint age;
    }
    
    mapping(bool => mapping(string => Person[])) people;
    
    Person[] private participants;
    
    event PersonAdded(Person _person);
    event ParticipantsChoosen(Person _girl, Person _boy, uint _startDate, uint _endDate);
    
    constructor() public {
        durationTime = 5 minutes;
    }
    
    modifier enoughCandidates() {
        uint nbOfQualifiedGirls = people[true][Female].length;
        uint nbOfQualifiedBoys = people[true][Male].length;
        require(nbOfQualifiedGirls >= 1 && nbOfQualifiedBoys >= 1, 'Not enough candidates, add more people!');
        _;
    }
    
    modifier onlyAfter() {
        require(hasStarted && block.timestamp >= endDate, 'Game has not ended yet!');
        _;
    }
    
    modifier onlyBefore() {
        require(!hasStarted, 'Game has already started!');
        _;
    }

    function addPerson(string memory _gender, uint _age) onlyBefore public {
        string memory _g = _formatGender(_gender);
        people[_age >= 12 && _age <= 18][_g].push(Person(_g, _age));
        emit PersonAdded(Person(_g, _age));
    }
    
    function chooseParticipants() onlyBefore enoughCandidates public {
        uint8 _randForGirls = _randomNumber(uint8(people[true][Female].length - 1));
        uint8 _randForBoys = _randomNumber(uint8(people[true][Male].length - 1));
        Person memory _choosenGirl = people[true][Female][_randForGirls];
        Person memory _choosenBoy = people[true][Male][_randForBoys];
        participants.push(_choosenGirl);
        participants.push(_choosenBoy);
        _setGameDates();
        emit ParticipantsChoosen(_choosenGirl, _choosenBoy, startDate, endDate);
    }
    
    
    function getNbOfGirls() public view returns (uint) {
        return people[true][Female].length + people[false][Female].length;
    }
    
    function getNbOfBoys() public view returns (uint) {
        return people[true][Male].length + people[false][Male].length;
    }
    
    function getNbOfPeople() public view returns (uint) {
        return getNbOfGirls() + getNbOfBoys();
    }
    
    function gameResult() public onlyAfter returns (bool _stillAlive) {
        // In case you want to check the result again. We could also destroy the contract but...
        if (!isFinalResultDefined) {
            finalResult = _randomNumber(1) == 1;
        }
        return finalResult;
    }
    
    function _setGameDates() private {
        startDate = block.timestamp;
        endDate = startDate + durationTime;
        hasStarted = true;
    }
    
    // Not fan, usually I prefer to use enum values but I'm not sure what's the best practice in this case
    function _formatGender(string memory _gender) private pure returns (string memory) {
        if (_compareStrings(_gender, 'boy') || _compareStrings(_gender, 'boys') || _compareStrings(_gender, 'male')) {
            return Male;
        }
        if (_compareStrings(_gender, 'girl') || _compareStrings(_gender, 'girls') || _compareStrings(_gender, 'female')) {
            return Female;
        }
        revert('Unknown gender');
    }
    
    function _compareStrings(string memory _a, string memory _b) internal pure returns (bool) {
        return keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }
    
    function _randomNumber(uint8 _max) private view returns (uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % (_max + 1));
    }
}
