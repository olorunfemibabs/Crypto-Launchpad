// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20 {
    constructor(string memory _name, string memory _symbol, uint _amount, address stakingContract) ERC20(_name, _symbol) {
        _mint(stakingContract, _amount);
    }
}