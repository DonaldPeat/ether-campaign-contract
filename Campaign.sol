pragma solidity ^0.4.17;

contract CampaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(uint minimum,string title, string description, uint threshold) public {
        address newCampaign = new Campaign(minimum, msg.sender,title,description,threshold);
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns(address[]){
        return deployedCampaigns;
    }
}

contract Campaign{

    uint public minimumContribution;
    uint public approversCount;
    uint public approvalThreshold;
    string public campaignTitle;
    string public campaignDescription;
    address public manager;
    mapping(address => bool)public approvers;


    struct Request {

        bool complete;
        uint approvalCount;
        uint value;
        string description;
        address recipient;
        mapping(address => bool) approvals;
    }


    Request[] public requests;


    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    function Campaign(uint minimum, address creator, string title, string description, uint threshold ) public {
        minimumContribution = minimum;
        manager = creator;
        campaignTitle = title;
        campaignDescription = description;
        approvalThreshold = threshold;
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

    function getSummary() public view returns (
      uint, uint, uint, uint, address, string, string, uint
      ){
      return (
          minimumContribution,
          this.balance,
          requests.length,
          approversCount,
          manager,
          campaignTitle,
          campaignDescription,
          approvalThreshold
      );
    }

    function getRequestsCount() public view returns (uint) {
      return requests.length;
    }

}
