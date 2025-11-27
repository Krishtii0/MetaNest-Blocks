// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title MetaNestBlocks
 * @dev Hierarchical registry of "nests" and their contained blocks
 * @notice Allows creating parent nests and attaching multiple child blocks to each nest
 */
contract MetaNestBlocks {
    address public owner;

    struct Nest {
        uint256 id;
        address creator;
        string  label;
        string  metadataURI;   // optional off-chain metadata
        uint256 createdAt;
        bool    isActive;
    }

    struct BlockItem {
        uint256 id;
        uint256 nestId;
        address creator;
        string  label;
        string  contentURI;    // reference to content (IPFS/HTTPS/etc.)
        uint256 createdAt;
        bool    isActive;
    }

    uint256 public totalNests;
    uint256 public totalBlocks;

    // nestId => Nest
    mapping(uint256 => Nest) public nests;

    // blockId => BlockItem
    mapping(uint256 => BlockItem) public blocksById;

    // nestId => blockIds[]
    mapping(uint256 => uint256[]) public blocksOfNest;

    // creator => nestIds[]
    mapping(address => uint256[]) public nestsOf;

    // creator => blockIds[]
    mapping(address => uint256[]) public blocksOf;

    event NestCreated(
        uint256 indexed nestId,
        address indexed creator,
        string label,
        string metadataURI,
        uint256 createdAt
    );

    event NestStatusUpdated(
        uint256 indexed nestId,
        bool isActive,
        uint256 timestamp
    );

    event BlockCreated(
        uint256 indexed blockId,
        uint256 indexed nestId,
        address indexed creator,
        string label,
        string contentURI,
        uint256 createdAt
    );

    event BlockStatusUpdated(
        uint256 indexed blockId,
        bool isActive,
        uint256 timestamp
    );

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier nestExists(uint256 nestId) {
        require(nests[nestId].creator != address(0), "Nest not found");
        _;
    }

    modifier blockExists(uint256 blockId) {
        require(blocksById[blockId].creator != address(0), "Block not found");
        _;
    }

    modifier onlyNestCreator(uint256 nestId) {
        require(nests[nestId].creator == msg.sender, "Not nest creator");
        _;
    }

    modifier onlyBlockCreator(uint256 blockId) {
        require(blocksById[blockId].creator == msg.sender, "Not block creator");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Create a new nest
     * @param label Human-readable label for the nest
     * @param metadataURI Off-chain metadata pointer (optional, can be empty)
     */
    function createNest(string calldata label, string calldata metadataURI)
        external
        returns (uint256 nestId)
    {
        nestId = totalNests;
        totalNests += 1;

        nests[nestId] = Nest({
            id: nestId,
            creator: msg.sender,
            label: label,
            metadataURI: metadataURI,
            createdAt: block.timestamp,
            isActive: true
        });

        nestsOf[msg.sender].push(nestId);

        emit NestCreated(nestId, msg.sender, label, metadataURI, block.timestamp);
    }

    /**
     * @dev Update active status of a nest
     * @param nestId Nest identifier
     * @param active New active state
     */
    function setNestActive(uint256 nestId, bool active)
        external
        nestExists(nestId)
        onlyNestCreator(nestId)
    {
        nests[nestId].isActive = active;
        emit NestStatusUpdated(nestId, active, block.timestamp);
    }

    /**
     * @dev Create a new block under a specific nest
     * @param nestId Parent nest identifier
     * @param label Label for the block
     * @param contentURI Reference to the block content
     */
    function createBlock(
        uint256 nestId,
        string calldata label,
        string calldata contentURI
    )
        external
        nestExists(nestId)
        returns (uint256 blockId)
    {
        require(nests[nestId].isActive, "Nest inactive");

        blockId = totalBlocks;
        totalBlocks += 1;

        blocksById[blockId] = BlockItem({
            id: blockId,
            nestId: nestId,
            creator: msg.sender,
            label: label,
            contentURI: contentURI,
            createdAt: block.timestamp,
            isActive: true
        });

        blocksOfNest[nestId].push(blockId);
        blocksOf[msg.sender].push(blockId);

        emit BlockCreated(blockId, nestId, msg.sender, label, contentURI, block.timestamp);
    }

    /**
     * @dev Update active status of a block
     * @param blockId Block identifier
     * @param active New active state
     */
    function setBlockActive(uint256 blockId, bool active)
        external
        blockExists(blockId)
        onlyBlockCreator(blockId)
    {
        blocksById[blockId].isActive = active;
        emit BlockStatusUpdated(blockId, active, block.timestamp);
    }

    /**
     * @dev Get all block IDs for a given nest
     * @param nestId Nest identifier
     */
    function getBlocksOfNest(uint256 nestId)
        external
        view
        nestExists(nestId)
        returns (uint256[] memory)
    {
        return blocksOfNest[nestId];
    }

    /**
     * @dev Get all nests created by a user
     * @param user Address to query
     */
    function getNestsOf(address user) external view returns (uint256[] memory) {
        return nestsOf[user];
    }

    /**
     * @dev Get all blocks created by a user
     * @param user Address to query
     */
    function getBlocksOf(address user) external view returns (uint256[] memory) {
        return blocksOf[user];
    }

    /**
     * @dev Transfer contract ownership
     * @param newOwner New owner address
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        address prev = owner;
        owner = newOwner;
        emit OwnershipTransferred(prev, newOwner);
    }
}
