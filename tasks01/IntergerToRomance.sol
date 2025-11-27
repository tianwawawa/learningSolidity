/ SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract IntegerToRomance {
    function intToRoman(uint num) external pure returns(string memory){
    string[4] memory thousands = ["", "M", "MM", "MMM"];
    string[10] memory  hundreds = ["", "C", "CC", "CCC", "CD", "D", "DC", "DCC", "DCCC", "CM"];
    string[10] memory  tens     = ["", "X", "XX", "XXX", "XL", "L", "LX", "LXX", "LXXX", "XC"];
    string[10] memory  ones     = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX"];
   
    return string(abi.encodePacked(
    thousands[(num / 1000)],
    hundreds[(num % 1000 / 100)],
    tens[(num % 100 / 10)],
    ones[num % 10]
    ));
    }
}