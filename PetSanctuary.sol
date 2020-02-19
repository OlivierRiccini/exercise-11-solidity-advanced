pragma solidity ^0.6.1;

contract PetSanctuary  {
    address owner;
   
    struct Adopter {
        uint age;
        string gender;
        string animalKind;
        uint adoptionDate;
        bool hasAdopted;
    }
   
    struct Animal {
        bool accepted;
        uint quantity;
    }
   
    mapping(string => Animal) private animals;
    mapping(address => Adopter) private adopters;
   
    event AnimalsAdded(string _kind, uint _quantity, uint _newTotal);
    event AnimalAdopted(address _adopter, uint _adoptionDate, uint _newTotal);
    event AnimalBack(address _adopter, uint _newTotal);
   
    constructor() public {
        owner = msg.sender;
        animals['fish'].accepted = true;
        animals['cat'].accepted = true;
        animals['dog'].accepted = true;
        animals['rabbit'].accepted = true;
        animals['parrot'].accepted = true;
    }
   
    modifier onlyOwner() {
        require(msg.sender == owner, 'Only owner can perform this task');
        _;
    }
   
    modifier availableGenders(string memory _gender) {
        bool availbleGender = _compareStrings(_gender, 'female') || _compareStrings(_gender, 'male');
        require(availbleGender, 'Unknown gender, should be either female or male');
        _;
    }
   
    modifier isFirstFiveMinutes() {
        bool _isOnTime = adopters[msg.sender].hasAdopted && block.timestamp < (adopters[msg.sender].adoptionDate + 5 minutes);
        require(_isOnTime, 'Sorry, it is to late to give your animal back');
        _;
    }
   
    modifier onlyAcceptedAnimals(string memory _animalKind) {
        require(animals[_animalKind].accepted, 'Kind of animal not accepted');
        _;
    }
   
    function add(string memory _animalKind, uint _howManyPieces) public onlyOwner onlyAcceptedAnimals(_animalKind) {
        animals[_animalKind].quantity += _howManyPieces;
        emit AnimalsAdded(_animalKind, _howManyPieces, animals[_animalKind].quantity);
    }
   
    function buy(uint _personAge, string memory _personGender, string memory _animalKind) public availableGenders(_personGender) onlyAcceptedAnimals(_animalKind) {
        _checkExceptions(_personAge, _personGender, _animalKind);
        animals[_animalKind].quantity -= 1;
        uint _timestamp = block.timestamp;
        adopters[msg.sender] = Adopter(_personAge, _personGender, _animalKind, _timestamp, true);
        emit AnimalAdopted(msg.sender, _timestamp, animals[_animalKind].quantity);
    }
   
    function giveBackAnimal(string memory _animalKind) public isFirstFiveMinutes {
        animals[_animalKind].quantity += 1;
        delete adopters[msg.sender];
        emit AnimalBack(msg.sender, animals[_animalKind].quantity);
    }
   
    function _checkExceptions(uint _personAge, string memory _personGender, string memory _animalKind) private view {
        _isFirstAdoption();
        _enoughStock(_animalKind);
        _checkGenderExceptions(_personAge, _personGender, _animalKind);
    }
   
    function _isFirstAdoption() private view {
        if(adopters[msg.sender].hasAdopted) {
            revert('You already have adopted an animal');
        }
    }
   
    function _enoughStock(string memory _animalKind) private view {
        if(animals[_animalKind].quantity == 0) {
            revert('No more stock available');
        }
    }
   
    function _checkGenderExceptions(uint _personAge, string memory _personGender, string memory _animalKind) private pure {
         if(_compareStrings(_personGender, 'male') && (!_compareStrings(_animalKind, 'dog') && !_compareStrings(_animalKind, 'fish'))) {
            revert('Men can only buy dogs or fish');
        }
        if((_compareStrings(_personGender, 'female') && _personAge < 40) && _compareStrings(_animalKind, 'cat')) {
            revert('Women under 40 are not allowed to buy cats');
        }
    }
   
    function _compareStrings(string memory _a, string memory _b) internal pure returns (bool) {
        return keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }
}