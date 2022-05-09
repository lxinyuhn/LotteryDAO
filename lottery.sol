// SPDX-License-Identifier: GPL-3.0-only
// This is a PoC to use the staking precompile wrapper as a Solidity developer.
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract LotteryDAO is AccessControl {

    using SafeMath for uint256;
   
    address[] members;
    uint256 public totalStake;
    uint  public startBlocknumber;
    uint256 public constant lotteryPrice = 1 ether;
    
    event deposit(address indexed _from, uint _value);
    event lotteryResult( address indexed _to, uint _value);

    constructor() {

    }

    // Increase member stake via a payable function and automatically stake the added amount if possible
    function add_stake() external payable {
        require(msg.value == 1 ether, "Lottery value only accpet 1 ether.");
        if (startBlocknumber == 0){
            startBlocknumber = block.timestamp; 
        }
        totalStake = totalStake.add(msg.value);
        members.push(msg.sender);
        emit deposit(msg.sender, msg.value);
        if (members.length >= 10 || block.timestamp - startBlocknumber > 3600){
            //简化合约,用个伪随机
            uint winner = block.number % members.length;
            address payable payAddr = payable(members[winner]); 
            Address.sendValue(payAddr, totalStake);
            emit lotteryResult(payAddr, totalStake);
            totalStake = 0;
            delete members;
            startBlocknumber = 0;
        }
    }

    // Function for a user to withdraw their stake
    function transfer_member(address payable account) public {
        for(uint i=0; i<members.length; i++ ){
            if (members[i] == msg.sender){
                members[i] = account;
            }
        }
    }

}
