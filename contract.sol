
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TriviaGame {
    address public owner;
    uint256 public rewardAmount;
    
    struct Question {
        string questionText;
        bytes32 correctAnswerHash;
        bool exists;
    }

    mapping(uint256 => Question) public questions;
    mapping(address => uint256) public playerRewards;
    uint256 public questionCount;

    event QuestionAdded(uint256 questionId, string questionText);
    event AnsweredCorrectly(address player, uint256 questionId, uint256 reward);
    event RewardWithdrawn(address player, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(uint256 _rewardAmount) {
        owner = msg.sender;
        rewardAmount = _rewardAmount;
    }

    function addQuestion(uint256 questionId, string memory questionText, string memory correctAnswer) public onlyOwner {
        require(!questions[questionId].exists, "Question ID already exists");
        questions[questionId] = Question(questionText, keccak256(abi.encodePacked(correctAnswer)), true);
        questionCount++;
        emit QuestionAdded(questionId, questionText);
    }

    function answerQuestion(uint256 questionId, string memory answer) public {
        require(questions[questionId].exists, "Question does not exist");
        require(keccak256(abi.encodePacked(answer)) == questions[questionId].correctAnswerHash, "Incorrect answer");

        playerRewards[msg.sender] += rewardAmount;
        emit AnsweredCorrectly(msg.sender, questionId, rewardAmount);
    }

    function withdrawRewards() public {
        uint256 amount = playerRewards[msg.sender];
        require(amount > 0, "No rewards to withdraw");

        playerRewards[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit RewardWithdrawn(msg.sender, amount);
    }

    function depositFunds() public payable onlyOwner {}

    function getQuestion(uint256 questionId) public view returns (string memory) {
        require(questions[questionId].exists, "Question does not exist");
        return questions[questionId].questionText;
    }

    function checkRewards(address player) public view returns (uint256) {
        return playerRewards[player];
    }
}
