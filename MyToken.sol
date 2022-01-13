// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MyToken is ERC20, ReentrancyGuard {
    address private marketPlaceAddress;

    constructor(address marketAddress) payable ERC20("GOLDTEST", "GT") {
        _mint(msg.sender, 100);
        marketPlaceAddress = marketAddress;
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    function custTransfer(
        address sender,
        address recipient,
        uint256 quantity
    ) public payable nonReentrant {
        require(msg.sender == marketPlaceAddress, "Contract is not authorized");
        _transfer(sender, recipient, quantity);
    }

    function getUserBalance(address user) public view returns (uint256) {
        require(msg.sender == marketPlaceAddress, "Contract is not authorized");
        return balanceOf(user);
    }
}
