// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PeerLedWorkshops {
    struct Workshop {
        string title;
        string description;
        address host;
        uint256 participants;
        uint256 reward;
        bool isCompleted;
    }

    mapping(uint256 => Workshop) public workshops;
    mapping(address => uint256) public rewards;
    address public owner;
    uint256 public nextWorkshopId;
    uint256 public rewardPerParticipant;

    event WorkshopCreated(uint256 workshopId, string title, address host);
    event WorkshopCompleted(uint256 workshopId, uint256 totalReward);
    event RewardClaimed(address host, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    constructor(uint256 _rewardPerParticipant) {
        owner = msg.sender;
        rewardPerParticipant = _rewardPerParticipant;
    }

    function createWorkshop(string memory _title, string memory _description) external {
        workshops[nextWorkshopId] = Workshop({
            title: _title,
            description: _description,
            host: msg.sender,
            participants: 0,
            reward: 0,
            isCompleted: false
        });
        emit WorkshopCreated(nextWorkshopId, _title, msg.sender);
        nextWorkshopId++;
    }

    function completeWorkshop(uint256 _workshopId, uint256 _participants) external onlyOwner {
        Workshop storage workshop = workshops[_workshopId];
        require(!workshop.isCompleted, "Workshop already completed.");

        workshop.participants = _participants;
        workshop.reward = _participants * rewardPerParticipant;
        workshop.isCompleted = true;
        rewards[workshop.host] += workshop.reward;

        emit WorkshopCompleted(_workshopId, workshop.reward);
    }

    function claimReward() external {
        uint256 amount = rewards[msg.sender];
        require(amount > 0, "No rewards to claim.");

        rewards[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit RewardClaimed(msg.sender, amount);
    }

    function fundContract() external payable onlyOwner {}

    function updateRewardPerParticipant(uint256 _newReward) external onlyOwner {
        rewardPerParticipant = _newReward;
    }

    function getWorkshop(uint256 _workshopId) external view returns (Workshop memory) {
        return workshops[_workshopId];
    }
}