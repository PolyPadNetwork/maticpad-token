// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PolyPADToken is ERC20 {
    constructor(string memory _name, string memory _symbol)
        public
        ERC20(_name, _symbol)
    {
        _mint(msg.sender, 200e6 * 1e18);
    }
}
