/ **
✅ 创建一个名为Voting的合约，包含以下功能：
一个mapping来存储候选人的得票数
一个vote函数，允许用户投票给某个候选人
一个getVotes函数，返回某个候选人的得票数
一个resetVotes函数，重置所有候选人的得票数
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    //一个mapping来存储候选人的得票数
    mapping(uint256=>uint256) public tickets;
    //所有者
    address public owner;
    //候选人id数组
    uint256[] private candidatesIds;
    constructor(){
        owner = msg.sender;
    }
    modifier onlyOwner(){
        require(msg.sender == owner, "permission denied!");
        _;
    }

    //允许用户投票给某个候选人
    function vote(uint256 _id) external{
        if(tickets[_id] == 0){
            candidatesIds.push(_id);
        }
        tickets[_id]++;
    } 

    //返回某个候选人的得票数
    function getVotes(uint256 _id) external view returns(uint256){
        return tickets[_id];
    }

    // 重置所有候选人的得票数
    function resetVotes() external onlyOwner {
        for(uint256 i = 0; i < candidatesIds.length; i++ ) {
            tickets[candidatesIds[i]] = 0;
        }
        delete candidatesIds;
    }

}