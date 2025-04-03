// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token42 is ERC20, Ownable {

    constructor() ERC20("Token42", "T42") Ownable(msg.sender) {
    }

    function decimals() public pure override returns (uint8) {
        return 4;
    }

    function myBalance() view public returns (uint256) {
        return balanceOf(msg.sender);
    }

    function burn(uint256 amount) external  {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _burn(msg.sender, amount);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Mint to zero address");
        _mint(to, amount);
    }

    function burnFrom(address from, uint256 amount) external onlyOwner {
        require(balanceOf(from) >= amount, "Insufficient balance");
        _burn(from, amount);
    }
}