// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
contract BeggingContract {
    // 每记录每个捐赠者的地址和捐赠金额
    mapping(address => uint256) public donations;
    // 记录所有捐赠者的地址
    address[] private donors;
    // 合约拥有者地址
    address private owner;
    constructor() {
        owner = msg.sender;
    } 
    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // 查询某个地址的捐赠金额
    function getDonation(address addr) view public returns(uint256){
        return donations[addr];
    }

    // 捐赠函数，接受以太币捐赠
    function donate() external payable {
        require(msg.value > 0, "Zero donation");
        if(donations[msg.sender] == 0) {
            donors.push(msg.sender);
        }
        donations[msg.sender] += msg.value;
    }

    // 查询捐赠排行榜前3名  
    function rankTop3() public view returns(address[3] memory addrs) {
        address[] memory tempDonors = donors;
        uint256 len = tempDonors.length;
        if(len == 0) {
            return (addrs);
        }
        for (uint i = 0; i < len - 1; i++) {
            uint j = i+1;
            while (j < len && donations[tempDonors[i]] < donations[tempDonors[j]]) {
                // 交换地址
                address tempAddr = tempDonors[i];
                tempDonors[i] = tempDonors[j];
                tempDonors[j] = tempAddr;
                // 交换金额
                j++;        
                
            }
        }
        for (uint k = 0; k < 3 && k < len; k++) {
            addrs[k] = donors[k];
        }
    }
    
    // 提现函数，只有合约拥有者可以调用
    function withdraw(address payable to) external onlyOwner returns(bool) {
        uint256 amount = address(this).balance;
        to.transfer(amount);
        return true;
    } 
}