// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "./E7L.sol";

struct E7LInstance {
    uint256 prev;
    address instance;
    uint256 index;
    uint256 next;
}

contract E7LFactory {
    IERC721 public immutable defaultParent;
    address public owner;
    mapping(address => bool) public isAdmin;
    mapping(uint256 => E7LInstance) public instances;
    uint256 public first = 1;
    uint256 public last = 0;
    uint256 public amount;

    modifier onlyOwner {
        require(msg.sender == owner, "E7L-Factory: Not owner");
        _;
    }

    modifier onlyAdmin {
        require(msg.sender == owner || isAdmin[msg.sender] == true, "E7L-Factory: Not admin");
        _;
    }

    constructor(
        address _defaultParent
    ) {
        owner = msg.sender;
        defaultParent = IERC721(_defaultParent);
    }

    function newE7L(string memory name_, string memory symbol_, string memory baseURI_, address parent_) public onlyAdmin {
        address instance = address(new E7L(name_, symbol_, address(parent_), baseURI_));
        addInstance(instance);
    }

    function newE7L(string memory name_, string memory symbol_, string memory baseURI_) public {
        newE7L(name_, symbol_, baseURI_, address(defaultParent));
    }

    function addInstance(address instance) public onlyAdmin {
        instances[last].next = last + 1;
        instances[last + 1] = E7LInstance(last, instance, ++last, 0);
        ++amount;
    }

    function getIndex(address instance) public view returns(uint256) {
        for (uint256 i = instances[first].index; i <= amount; i = instances[i].next) {
            if (instances[i].instance == instance)
                return i;
        }
        return 0;
    }

    function removeInstance(uint256 index) public onlyAdmin {
        require(index > 0, "E7L-Factory: Invalid index");
        E7LInstance storage prev = instances[instances[index].prev];
        E7LInstance storage next = instances[instances[index].next];

        prev.next = next.index;
        next.prev = prev.index;
    }

    function removeInstance(address instance) public onlyAdmin {
        uint256 index = getIndex(instance);
        removeInstance(index);
    }

    function setAdmin(address wallet_, bool is_) public onlyOwner {
        require(isAdmin[wallet_] != is_, "E7L-Factory: Already set");
        isAdmin[wallet_] = is_;
    }
}
