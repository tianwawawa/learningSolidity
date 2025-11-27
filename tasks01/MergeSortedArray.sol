// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract MergeSortedArray {
    uint[] public sorted;
   function mergeSortedArray(uint[] memory a, uint[] memory b) public returns(uint[] memory){
            uint i = 0;
            uint j = 0;            
            while (i < a.length || j < b.length) {
                if (j >= b.length) {
                    sorted.push(a[i++]);
                } else if (i >= a.length) {
                    sorted.push(b[j++]);
                } else if (a[i] >= b[j]) {
                    sorted.push(b[j++]);
                } else {
                    sorted.push(a[i++]);
                }
            }
            return sorted;
   }
}