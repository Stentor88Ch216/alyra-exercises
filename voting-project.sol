pragma solidity >=0.7.0 <0.9.0;
//pragma solidity 0.8.17;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Voting is Ownable {


    // WORKFLOW ------------------------------------------------
    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    WorkflowStatus public status = WorkflowStatus.RegisteringVoters;

    event VoterRegistered(address _address);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted(address voter, uint proposalId);

    function changeStatus(WorkflowStatus _newStatus) private {
        emit WorkflowStatusChange(status, _newStatus);
        status = _newStatus;
    }


    // VOTERS ------------------------------------------------
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    mapping(address => Voter) voters;

    function registerVoter(address _address) public onlyOwner {
        require(status == WorkflowStatus.RegisteringVoters, "Voters registration is closed!");
        voters[_address] = Voter(true, false, 0);
        emit VoterRegistered(_address);
    }

    // PROPOSALS ------------------------------------------------
    function startProposalsRegistrations() public onlyOwner {
        changeStatus(WorkflowStatus.ProposalsRegistrationStarted);
    }

    struct Proposal {
        string description;
        uint voteCount;
    }

    Proposal[] proposals;

    function addProposal(string memory _proposalDescription) public {
        require(status == WorkflowStatus.ProposalsRegistrationStarted, "Proposal registration is closed!");
        require(voters[msg.sender].isRegistered, "You are not a registrated voter!");
        //require(_proposalDescription.length != 0, "The proposal description cannot be empty!");
        proposals.push(Proposal(_proposalDescription, 0));
        emit ProposalRegistered(proposals.length -1);
    }

    function closeProposalsRegistrations() public onlyOwner {
        changeStatus(WorkflowStatus.ProposalsRegistrationEnded);
    }


    // VOTES ------------------------------------------------
    function startVotingSession() public onlyOwner {
        changeStatus(WorkflowStatus.VotingSessionStarted);
    }

    function vote(uint _votedProposalId) public {
        require(status == WorkflowStatus.VotingSessionStarted, "Voting session is closed!");
        require(voters[msg.sender].isRegistered, "You are not a registrated voter!");
        require(!voters[msg.sender].hasVoted, "You have already voted!");
        require(_votedProposalId < proposals.length, "This proposal doesn't exist!");
        proposals[_votedProposalId].voteCount ++;
        emit Voted(msg.sender, _votedProposalId);
    }

    function closeVotingSession() public onlyOwner {
        changeStatus(WorkflowStatus.VotingSessionEnded);
    }

    // RESULTS ------------------------------------------------
    uint winnerId;

    function declareWinner() public onlyOwner {
        require(status == WorkflowStatus.VotingSessionEnded, "The voting session has not been ended yet!");

        for(uint i=0; i < proposals.length; i++) {
            if(proposals[i].voteCount > proposals[winnerId].voteCount) {
                winnerId = i;
                // TODO : implement the case when there are several winning proposals
            }
        }
        changeStatus(WorkflowStatus.VotesTallied);
    }

    function getWinnerDetails() public view returns (Proposal memory) {
        require(status == WorkflowStatus.VotesTallied, "No winner has been declared yet!");
        return proposals[winnerId];
    }

}
