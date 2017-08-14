pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/ERC20.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

/* Centralized Administrator */
contract MineableToken is Ownable {

    event Mine(address indexed to, uint value);

    bytes32 public currentChallenge; //
    uint public timeOfLastProof; // time of last challenge solved
    uint public difficulty = 10**32; // Difficulty starts low
    uint public baseReward = 1;
    bool public incrementalRewards = true;

    ERC20 public token;

    function MineableToken(ERC20 _token) {
        token = _token;
    }

    // Change the difficulty
    function setDifficulty(uint newDifficulty) onlyOwner {
        difficulty = newDifficulty;
    }

    // Change the reward
    function setBaseReward(uint newReward) onlyOwner {
        baseReward = newReward;
    }

    // Change if the reward should increment or not
    function isIncremental(bool shouldRewardIncrement) onlyOwner {
        incrementalRewards = shouldRewardIncrement;
    }

    // calculate rewards
    function calculateReward() returns (uint reward) {
        if (incrementalRewards == true) {
            reward = (now - timeOfLastProof) / 60 seconds; // Increase reward over time????
        } else {
            reward = baseReward;
        }

        return reward;
    }

    function proofOfWork(uint nonce) {
        bytes8 n = bytes8(sha3(nonce, currentChallenge)); // generate random hash based on input
        if (n < bytes8(difficulty)) revert();

        uint timeSinceLastProof = (now - timeOfLastProof); // Calculate time since last reward
        if (timeSinceLastProof < 5 seconds) revert(); // Do not reward too quickly

        uint reward = calculateReward();

        if (token.balanceOf(address(this)) < reward) revert(); // Make sure we have enough to send
        token.transfer(this, msg.sender, reward); // reward to winner grows over time

        difficulty = difficulty * 10 minutes / timeSinceLastProof + 1; // Adjusts the difficulty

        timeOfLastProof = now;
        currentChallenge = sha3(nonce, currentChallenge, block.blockhash(block.number - 1)); // Save hash for next proof

        Mine(msg.sender, reward); // execute an event reflecting the change

        return reward;
    }

}
