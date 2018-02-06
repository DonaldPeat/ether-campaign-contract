pragma solidity ^0.4.17;

contract Campaign{

    address public manager;
    uint public minimumContribution;
    address[] public approvers;

    struct Request {
        string description;
        uint value;
        address recipient;
        bool complete;
    }

    Request[] public requests;

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    function Campaign(uint minimum) public {
        manager = msg.sender;
        minimumContribution = minimum;
    }

    function contribute () public payable {
        require(msg.value >= minimumContribution);
        approvers.push(msg.sender);
    }

    function createRequest(string description, uint value, address recipient) public restricted{
        Request memory newRequest = Request({
            description: description,
            value: value,
            recipient: recipient,
            complete: false
        });

        requests.push(newRequest);

    }


}
