// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

/*
* @author Thomas
* @notice Alyra "Voting" project
*/

contract Voting is Ownable {

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
    }


    WorkflowStatus public status = WorkflowStatus.RegisteringVoters;
    mapping(address => Voter) voters;
    Proposal[] proposals;
    uint winnerId; // The array index of the winning proposal


    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event VoterRegistered(address _address);
    event ProposalRegistered(uint proposalId);
    event Voted(address voter, uint proposalId);


    // The next 4 functions are used by the owner of the voting process (the one who deployed the contract) to change the workflow status.
    // The workflow status is then used across the contract to enable or disable some functionnalities.
    function startProposalsRegistrations() public onlyOwner {
        changeStatus(WorkflowStatus.ProposalsRegistrationStarted);
    }

    function closeProposalsRegistrations() public onlyOwner {
        changeStatus(WorkflowStatus.ProposalsRegistrationEnded);
    }

    function startVotingSession() public onlyOwner {
        changeStatus(WorkflowStatus.VotingSessionStarted);
    }

    function closeVotingSession() public onlyOwner {
        changeStatus(WorkflowStatus.VotingSessionEnded);
    }


    /// This function lets the owner register new voters
    /// @param _address the address of the registered voter
    function registerVoter(address _address) public onlyOwner {
        require(status == WorkflowStatus.RegisteringVoters, "Voters registration is closed!");
        voters[_address] = Voter(true, false, 0);
        emit VoterRegistered(_address);
    }

    
    /// This function lets any registered voter add a new proposal
    /// @param _proposalDescription the content of the proposal (cannot be empty)
    function addProposal(string memory _proposalDescription) public {
        require(status == WorkflowStatus.ProposalsRegistrationStarted, "Proposal registration is closed!");
        require(voters[msg.sender].isRegistered, "You are not a registrated voter!");
        require(bytes(_proposalDescription).length != 0, "The proposal description cannot be empty!");
        proposals.push(Proposal(_proposalDescription, 0));
        emit ProposalRegistered(proposals.length -1);
    }


    function getProposalsDetails() public view returns(Proposal[] memory) {
        return proposals;
    }

    
    /// This function lets any registered voter declare their vote
    /// @param _votedProposalId the array index of the voted proposal
    function vote(uint _votedProposalId) public {
        require(status == WorkflowStatus.VotingSessionStarted, "Voting session is closed!");
        require(voters[msg.sender].isRegistered, "You are not a registrated voter!");
        require(!voters[msg.sender].hasVoted, "You have already voted!");
        require(_votedProposalId < proposals.length, "This proposal doesn't exist!");
        proposals[_votedProposalId].voteCount ++;
        voters[msg.sender].hasVoted = true;
        emit Voted(msg.sender, _votedProposalId);
    }

    
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

    function changeStatus(WorkflowStatus _newStatus) private {
        emit WorkflowStatusChange(status, _newStatus);
        status = _newStatus;
    }

}
