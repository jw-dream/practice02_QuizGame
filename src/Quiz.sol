// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Quiz{
    struct Quiz_item {
      uint id;
      string question;
      string answer;
      uint min_bet;
      uint max_bet;
   }
    
    address owner = msg.sender;
    mapping(address => uint256)[] public bets;
    uint quiz_index = 0;
    uint public vault_balance;
    mapping(uint => Quiz_item) quiz_list;
    mapping(uint => string) quiz_answer_list;
    mapping(address => uint) winner_balance_list;
    

    constructor () {
        owner = msg.sender;
        Quiz_item memory q;
        q.id = 1;
        q.question = "1+1=?";
        q.answer = "2";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        addQuiz(q);
    }


    function addQuiz(Quiz_item memory q) public {
        require(msg.sender == owner);
      
        quiz_answer_list[q.id] = q.answer;
        q.answer = "";

        quiz_index++;

        quiz_list[quiz_index] = q;
    }

    function getAnswer(uint quizId) public view returns (string memory){
        return quiz_answer_list[quizId];
    }

    function getQuiz(uint quizId) public view returns (Quiz_item memory) {
        return quiz_list[quizId];
    }

    function getQuizNum() public view returns (uint){
        return quiz_index;
    }
    
    function betToPlay(uint quizId) public payable {
        require(quiz_list[quizId].min_bet <= msg.value);
        require(quiz_list[quizId].max_bet >= msg.value);
        bets.push();
        bets[quizId-1][msg.sender] += msg.value;
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
        if(keccak256(abi.encode(quiz_answer_list[quizId])) == keccak256(abi.encode(ans))){
            winner_balance_list[msg.sender] += bets[quizId-1][msg.sender] * 2; 
            return true;
        }
        else{
            vault_balance += bets[quizId-1][msg.sender];
            bets[quizId-1][msg.sender] = 0;
            return false;
        }

    }

    function claim() public {
        uint money = winner_balance_list[msg.sender];
        winner_balance_list[msg.sender] = 0;
        (bool check,) = payable(msg.sender).call{value: money}("");
        require(check);

    }

    receive() payable external {}

}
