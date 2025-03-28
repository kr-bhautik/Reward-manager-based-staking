// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakeToken is ERC20 {

    address public owner;
    constructor() ERC20("StakeToken", "ST") {
        _mint(msg.sender, 100000 * 10 ** decimals());
        owner = msg.sender;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action.");
        _;
    }
}
//0xf0182395F73A8183463A97f3070a7AEa7BeC7604