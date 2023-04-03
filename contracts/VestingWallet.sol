// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract VestingWallet is Context {

    event EtherReleased(uint256 amount);
    event ERC20Released(address token, uint256 amount);

    uint256 private _released;
    mapping(address => uint256) private _erc20Released;
    address private immutable _beneficiary;
    uint256 private immutable _start;
    uint256 private immutable _duration;

    constructor(
        address beneficiaryAddress,
        uint256 startTimestamp,
        uint256 durationSeconds
    ) {
        require( beneficiaryAddress != address(0), "beneficiary should not be address zero" );
        _beneficiary = beneficiaryAddress;
        _start = startTimestamp;
        _duration = durationSeconds;
    }

    receive() external payable virtual {}

    function beneficiary() public view virtual returns(address) {
        return _beneficiary;
    }

    function start() public view virtual returns(uint256) {
        return _start;
    }

    function duration() public view virtual returns(uint256) {
        return _duration;
    }

    function released() public view virtual returns(uint256) {
        return _released;
    }

    function released(address token) public view virtual returns(uint256) {
        return _erc20Released[token];
    }

    function release() public virtual {
        uint256 releasable = vestedAmount(uint64(block.timestamp)) - released();
        _released += releasable;
        emit EtherReleased(releasable);
        Address.sendValue(payable(beneficiary()), releasable);
    }

    function release(address token) public virtual {
        uint256 releasable = vestedAmount(token, uint64(block.timestamp)) -
            released(token);
        _erc20Released[token] += releasable;
        emit ERC20Released(token, releasable);
        SafeERC20.safeTransfer(IERC20(token), beneficiary(), releasable);
    }

    function vestedAmount(uint256 timestamp) public view virtual returns (uint256) {
        return _vestingSchedule(address(this).balance + released(), timestamp);
    } 

    function vestedAmount(address token, uint256 timestamp) public view virtual returns (uint256) {
        return _vestingSchedule(IERC20(token).balanceOf(address(this)) + released(token), timestamp);
    }

    function _vestingSchedule(uint256 totalAllocation, uint256 timestamp) internal view virtual returns (uint256) {
         if (timestamp < start()) {
            return 0;
        } else if (timestamp > start() + duration()) {
            return totalAllocation;
        } else {
            return (totalAllocation * (timestamp - start())) / duration();
        }
    }
}

