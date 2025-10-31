// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// 题目描述：反转一个字符串。输入 "abcde"，输出 "edcba"
contract ReveseString {
    function reverseString(string memory _str) public pure returns(string memory){
            bytes memory _bytes = bytes(_str);
            uint256 left = 0;
            uint256 right = _bytes.length-1;
            for (uint i =0; left<= right; i++) 
            {
                bytes1 temp = _bytes[left];
                _bytes[left] = _bytes[right];
                _bytes[right] = temp;
                left++;
                right--;
            }
            return string(_bytes);
    }
}