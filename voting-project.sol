pragma solidity 0.8.17;

contract Whitelist {

    struct Person { // Structure de données
        string name;
        uint age;   
    }

    Person public moi;
    Person[] public persons;

    function modifyPerson(string memory _name, uint _age) public {
        moi.name = _name;
        moi.age = _age;
    }

    function add(string memory _name, uint _age) public {
        Person memory newPerson = Person(_name, _age);
        persons.push(newPerson);
    }

    function remove() public {
        persons.pop();
    }

    mapping (address => bool) whitelist;
    event Authorized(address _address);

    function authorize(address _address) public check {
        //require(check(), "You are not authorized !");
        whitelist[_address] = true;
        emit Authorized(_address);
    }

    /*
    function check() private view returns (bool) {
        return (whitelist[msg.sender] == true);
    }
    */

    modifier check() {
        require(whitelist[msg.sender] == true, "You are not authorized !");
        _;
    }

}


contract Time {
    function getTime() public view returns(uint) {
        return block.timestamp;
    }
}

