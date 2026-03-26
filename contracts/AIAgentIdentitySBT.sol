// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract AIAgentIdentitySBT {
    address public admin;
    uint256 public nextAgentId;
    
    mapping(address => string) public names;
    mapping(address => string) public descs;
    mapping(address => string) public avatars;
    mapping(address => uint256) public created;
    mapping(address => uint256) public scores;
    mapping(address => bool) public active;
    mapping(address => uint256) public agentIds;
    mapping(address => string[]) public skills;
    mapping(address => mapping(string => bool)) public hasSkill;
    
    event Minted(address indexed a, string name, uint256 id);
    event Updated(address indexed a);
    event SkillAdded(address indexed a, string name);
    event ScoreChanged(address indexed a, uint256 newScore);
    
    constructor() { admin = msg.sender; nextAgentId = 1; }
    
    function mint(string calldata name, string calldata desc, string calldata avatar) external {
        require(created[msg.sender] == 0, "exists");
        names[msg.sender] = name;
        descs[msg.sender] = desc;
        avatars[msg.sender] = avatar;
        created[msg.sender] = block.timestamp;
        scores[msg.sender] = 500;
        active[msg.sender] = true;
        agentIds[msg.sender] = nextAgentId++;
        emit Minted(msg.sender, name, agentIds[msg.sender]);
    }
    
    function updateName(string calldata name) external { 
        require(created[msg.sender] > 0, "not minted");
        names[msg.sender] = name; 
        emit Updated(msg.sender);
    }
    
    function updateDesc(string calldata desc) external { 
        require(created[msg.sender] > 0, "not minted");
        descs[msg.sender] = desc; 
        emit Updated(msg.sender);
    }
    
    function updateAvatar(string calldata avatar) external { 
        require(created[msg.sender] > 0, "not minted");
        avatars[msg.sender] = avatar; 
        emit Updated(msg.sender);
    }
    
    function addSkill(string calldata name) external {
        require(created[msg.sender] > 0, "not minted");
        require(!hasSkill[msg.sender][name], "exists");
        skills[msg.sender].push(name);
        hasSkill[msg.sender][name] = true;
        emit SkillAdded(msg.sender, name);
    }
    
    function updateScore(address a, int256 delta) external {
        require(msg.sender == admin, "not admin");
        require(created[a] > 0, "not minted");
        int256 ns = int256(scores[a]) + delta;
        if (ns < 0) ns = 0;
        if (ns > 1000) ns = 1000;
        scores[a] = uint256(ns);
        emit ScoreChanged(a, scores[a]);
    }
    
    function deactivate() external { 
        require(created[msg.sender] > 0, "not minted");
        active[msg.sender] = false; 
    }
    
    function reactivate() external { 
        require(created[msg.sender] > 0, "not minted");
        active[msg.sender] = true; 
    }
    
    function getInfo(address a) external view returns (
        string memory name, string memory desc, string memory avatar,
        uint256 _created, uint256 score, bool _active, uint256 skillCount
    ) {
        return (names[a], descs[a], avatars[a], created[a], scores[a], active[a], skills[a].length);
    }
    
    function getSkills(address a) external view returns (string[] memory) {
        return skills[a];
    }
}
