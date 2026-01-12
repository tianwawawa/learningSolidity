// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract RomanToInteger {
    mapping(bytes1 => uint) public romanceMap;
    uint[7] public intergerArray = [1,5,10,50,100,500,1000];
    bytes public romance = "IVXLCDM";
    constructor() {
         for (uint i = 0; i < intergerArray.length; i++){
            romanceMap[romance[i]] = intergerArray[i];
        }
    }
    function romanToInt(string memory s) external view returns(uint){
        bytes memory temp = bytes(s);
        uint result = 0;
        for (uint i = 0; i < temp.length; i++) 
        {
            if (i + 1 < temp.length && romanceMap[temp[i]] < romanceMap[temp[i+1]]) {
                result += (romanceMap[temp[i+1]] - romanceMap[temp[i]]);
                i++;
            } else {
                result += romanceMap[temp[i]];
            }
            
        }
        return result;
    }

}