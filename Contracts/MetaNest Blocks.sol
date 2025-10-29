// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MetaNest Blocks
 * @dev A simple decentralized property ownership registry using blockchain.
 */
contract MetaNestBlocks {

    struct Property {
        uint256 id;
        address owner;
        string name;
        string location;
        uint256 value;
    }

    uint256 public nextPropertyId;
    mapping(uint256 => Property) public properties;

    event PropertyRegistered(uint256 indexed id, address indexed owner, string name);
    event PropertyTransferred(uint256 indexed id, address indexed from, address indexed to);
    event PropertyUpdated(uint256 indexed id, uint256 oldValue, uint256 newValue);

    /**
     * @dev Register a new property
     */
    function registerProperty(string memory _name, string memory _location, uint256 _value) public {
        properties[nextPropertyId] = Property(nextPropertyId, msg.sender, _name, _location, _value);
        emit PropertyRegistered(nextPropertyId, msg.sender, _name);
        nextPropertyId++;
    }

    /**
     * @dev Transfer ownership of a property
     */
    function transferProperty(uint256 _id, address _newOwner) public {
        require(properties[_id].owner == msg.sender, "You are not the owner of this property");
        address oldOwner = properties[_id].owner;
        properties[_id].owner = _newOwner;
        emit PropertyTransferred(_id, oldOwner, _newOwner);
    }

    /**
     * @dev Update property value
     */
    function updatePropertyValue(uint256 _id, uint256 _newValue) public {
        require(properties[_id].owner == msg.sender, "Only the owner can update the property");
        uint256 oldValue = properties[_id].value;
        properties[_id].value = _newValue;
        emit PropertyUpdated(_id, oldValue, _newValue);
    }

    /**
     * @dev Fetch property details
     */
    function getProperty(uint256 _id) public view returns (Property memory) {
        return properties[_id];
    }
}
// 
update
// 
