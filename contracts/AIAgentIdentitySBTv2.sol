// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract AIAgentIdentitySBTv2 {
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
    mapping(address => bool) public minters;
    
    event Minted(address indexed to, string name, uint256 id, address indexed minter);
    event Updated(address indexed a);
    event SkillAdded(address indexed a, string name);
    event ScoreChanged(address indexed a, uint256 newScore);
    event MinterAdded(address indexed minter);
    event MinterRemoved(address indexed minter);
    
    constructor() { 
        admin = msg.sender; 
        nextAgentId = 1;
        minters[msg.sender] = true;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "not admin");
        _;
    }
    
    modifier onlyMinter() {
        require(minters[msg.sender], "not minter");
        _;
    }
    
    function mintTo(address to, string calldata name, string calldata desc, string calldata avatar, string[] calldata initialSkills) external onlyMinter returns (uint256) {
        require(to != address(0), "invalid address");
        require(created[to] == 0, "already has identity");
        require(bytes(name).length > 0, "name required");
        
        names[to] = name;
        descs[to] = desc;
        avatars[to] = avatar;
        created[to] = block.timestamp;
        scores[to] = 500;
        active[to] = true;
        
        uint256 agentId = nextAgentId++;
        agentIds[to] = agentId;
        
        for (uint256 i = 0; i < initialSkills.length && i < 20; i++) {
            if (!hasSkill[to][initialSkills[i]]) {
                skills[to].push(initialSkills[i]);
                hasSkill[to][initialSkills[i]] = true;
                emit SkillAdded(to, initialSkills[i]);
            }
        }
        
        emit Minted(to, name, agentId, msg.sender);
        return agentId;
    }
    
    function mintToSimple(address to, string calldata name, string calldata desc, string calldata avatar) external onlyMinter returns (uint256) {
        require(to != address(0), "invalid address");
        require(created[to] == 0, "already has identity");
        require(bytes(name).length > 0, "name required");
        
        names[to] = name;
        descs[to] = desc;
        avatars[to] = avatar;
        created[to] = block.timestamp;
        scores[to] = 500;
        active[to] = true;
        
        uint256 agentId = nextAgentId++;
        agentIds[to] = agentId;
        
        emit Minted(to, name, agentId, msg.sender);
        return agentId;
    }
    
    function addSkillTo(address to, string calldata name) external onlyMinter {
        require(created[to] > 0, "no identity");
        require(!hasSkill[to][name], "skill exists");
        require(skills[to].length < 20, "max skills");
        skills[to].push(name);
        hasSkill[to][name] = true;
        emit SkillAdded(to, name);
    }
    
    function updateName(string calldata name) external { 
        require(created[msg.sender] > 0, "no identity");
        names[msg.sender] = name; 
        emit Updated(msg.sender);
    }
    
    function updateDesc(string calldata desc) external { 
        require(created[msg.sender] > 0, "no identity");
        descs[msg.sender] = desc; 
        emit Updated(msg.sender);
    }
    
    function updateAvatar(string calldata avatar) external { 
        require(created[msg.sender] > 0, "no identity");
        avatars[msg.sender] = avatar; 
        emit Updated(msg.sender);
    }
    
    function deactivate() external { 
        require(created[msg.sender] > 0, "no identity");
        active[msg.sender] = false; 
    }
    
    function reactivate() external { 
        require(created[msg.sender] > 0, "no identity");
        active[msg.sender] = true; 
    }
    
    function updateScore(address a, int256 delta) external onlyAdmin {
        require(created[a] > 0, "no identity");
        int256 ns = int256(scores[a]) + delta;
        if (ns < 0) ns = 0;
        if (ns > 1000) ns = 1000;
        scores[a] = uint256(ns);
        emit ScoreChanged(a, scores[a]);
    }
    
    function addMinter(address minter) external onlyAdmin {
        minters[minter] = true;
        emit MinterAdded(minter);
    }
    
    function removeMinter(address minter) external onlyAdmin {
        minters[minter] = false;
        emit MinterRemoved(minter);
    }
    
    function transferAdmin(address newAdmin) external onlyAdmin {
        admin = newAdmin;
    }
    
    function getInfo(address a) external view returns (string memory name, string memory desc, string memory avatar, uint256 _created, uint256 score, bool _active, uint256 skillCount) {
        return (names[a], descs[a], avatars[a], created[a], scores[a], active[a], skills[a].length);
    }
    
    function getSkills(address a) external view returns (string[] memory) {
        return skills[a];
    }
    
    function hasIdentity(address a) external view returns (bool) {
        return created[a] > 0;
    }
}
