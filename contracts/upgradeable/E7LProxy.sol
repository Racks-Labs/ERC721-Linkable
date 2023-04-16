// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract E7LProxy is ERC1967Proxy {
    constructor(address logic_) ERC1967Proxy(logic_, "") {}
}
