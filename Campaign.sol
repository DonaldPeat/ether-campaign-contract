pragma solidity ^0.4.17;

contract Campaign{

    address public manager;
    uint public minimumContribution;
    mapping(address => bool)public approvers;
    uint public approversCount;


    struct Request {
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
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

        if (!approvers[msg.sender]) { //one approval vote per address
            approvers[msg.sender] = true;
            approversCount++;
        }
    }

    function createRequest(string description, uint value, address recipient) public restricted{
        Request memory newRequest = Request({
            description: description,
            value: value,
            recipient: recipient,
            complete: false,
            approvalCount: 0
        });

        requests.push(newRequest);
    }

    function approveRequest( uint index) public {
        Request storage request = requests[index];

        require(approvers[msg.sender]); //is a contributor
        require(!request.approvals[msg.sender]); //has not approved yet

        request.approvals[msg.sender] = true; //mark user as having voted
        request.approvalCount++; //increment total
    }

    function finalizeRequest(uint index) public payable restricted {
        Request storage request = requests[index];

        require(request.approvalCount > (approversCount / 2)); //require majority approval
        require(!request.complete);

        request.recipient.transfer(request.value);
        request.complete = true;
    }

}
