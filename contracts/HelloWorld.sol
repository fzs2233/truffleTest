// SPDX-License-Identifier: MIT
// Tells the Solidity compiler to compile only from v0.8.13 to v0.9.0
pragma solidity ^0.8.13;

contract HelloWorld {
    string strVar = "Hello World";
    function sayHello() public view returns(string memory) {
        return strVar;
    }
}