pragma solidity ^0.4.11;

import './Ownable.sol';
import './ERC20.sol';

/**
 * @title Mineable Token
 *
 * @dev Turns a wallet into a mine for a specified ERC20 token
 */
contract MineableToken is Ownable {

    event Mine(address indexed to, uint value);

    bytes32 public currentChallenge;
    uint public timeOfLastProof; // time of last challenge solved
    uint256 public difficulty = 10**32; // Difficulty starts low
    uint256 public baseReward = 1;
    bool public incrementalRewards = true;
    ERC20 public token;

    /**
     * @dev Constructor that sets the passed value as the token to be mineable.
     * @param _token ERC20 ERC20 compatible token
     */
    function MineableToken(ERC20 _token) {
        token = _token;
    }

    /**
     * @dev Change the difficulty
     * @param _difficulty uint256 difficulty to be set
     */
    function setDifficulty(uint256 _difficulty) onlyOwner {
        difficulty = _difficulty;
    }

    /**
     * @dev Change the reward
     * @param _baseReward uint256 base reward given when not incremental
     */
    function setBaseReward(uint256 _baseReward) onlyOwner {
        baseReward = _baseReward;
    }

    /**
     * @dev Change if the reward should increment or not
     * @param _shouldRewardIncrement bool Wehether the reward should be incremental or not
     */
    function isIncremental(bool _shouldRewardIncrement) onlyOwner {
        incrementalRewards = _shouldRewardIncrement;
    }

    /**
     * @dev Calculate the reward
     * @return uint256 Returns the amount to reward
     */
    function calculateReward() returns (uint256) {

        /* Check if we are incrementing reward */
        if (incrementalRewards == true) {
            return (now - timeOfLastProof) / 60 seconds; // Increase reward over time
        }

        return baseReward; // just return the base reward
    }

    /**
     * @dev Proof of work to be done for mining
     * @param nonce uint
     * @return uint The amount rewarded
     */
    function proofOfWork(uint nonce) returns (uint256) {
        bytes8 n = bytes8(sha3(nonce, currentChallenge)); // generate random hash based on input
        if (n < bytes8(difficulty)) revert();

        uint timeSinceLastProof = (now - timeOfLastProof); // Calculate time since last reward
        if (timeSinceLastProof < 5 seconds) revert(); // Do not reward too quickly

        uint256 reward = calculateReward();

        if (token.balanceOf(address(this)) < reward) revert(); // Make sure we have enough to send
        token.transferFrom(this, msg.sender, reward); // reward to winner grows over time

        difficulty = difficulty * 10 minutes / timeSinceLastProof + 1; // Adjusts the difficulty

        timeOfLastProof = now;
        currentChallenge = sha3(nonce, currentChallenge, block.blockhash(block.number - 1)); // Save hash for next proof

        Mine(msg.sender, reward); // execute an event reflecting the change

        return reward;
    }

}
