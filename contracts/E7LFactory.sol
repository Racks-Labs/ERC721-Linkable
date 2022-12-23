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
    address[] public instances;
    mapping(address => bool) public hasInstance;

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
        //TODO: call supports interface
        instances.push(instance);
        hasInstance[instance] = true;
    }

    function getIndex(address instance) public view returns(uint256) {
        require(hasInstance[instance] == true, "E7L-Factory: Non-existen istance");
        uint256 amount = instances.length;
        for (uint256 i = 0; i <= amount; ++i) {
            if (instances[i] == instance)
                return i;
        }
        return amount;
    }

    function removeInstance(uint256 index) public onlyAdmin {
        uint256 amount = instances.length;
        require(amount > 0, "E7L-Factory: No instances");
        require(index < amount, "E7L-Factory: Invalid index");

        address removed = instances[index];
        instances[index] = instances[amount - 1];
        instances[amount - 1] = removed;

        hasInstance[removed] = false;
        instances.pop();
    }

    function removeInstance(address instance) public {
        uint256 index = getIndex(instance);
        removeInstance(index);
    }

    function setAdmin(address wallet_, bool is_) public onlyOwner {
        require(isAdmin[wallet_] != is_, "E7L-Factory: Already set");
        isAdmin[wallet_] = is_;
    }
}
