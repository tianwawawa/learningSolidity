pragma solidity ^0.8.0;
contract BinarySearch {
    function binarySearch(uint[] memory nums,uint target) external pure returns(uint) {
    uint left = 0;
    uint right = nums.length - 1;
    while(left <= right){
        uint mid = (left + right) / 2;
        uint num = nums[mid];
        if(num > target){
            right = mid - 1;
        } else if(num < target) {
            left = mid + 1;
        } else {
           return mid; 
        }
    }
    return type(uint).max;
    }
}