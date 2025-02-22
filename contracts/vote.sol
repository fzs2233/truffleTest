// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Voting {
    // 修改构造函数，添加时间设置
    constructor(uint _durationInMinutes) {
        startTime = block.timestamp;
        endTime = startTime + (_durationInMinutes * 1 minutes);
        owner = msg.sender;
        proposers[msg.sender] = true;
    }
    // 投票提案结构
    struct Proposal {
        string description; // 提案描述
        uint voteCount;     // 得票数
        bool exists;       // 是否存在,这个是因为mapping类型在key不存在时会返回默认值，所以需要一个变量来判断是否存在  
    }

    // 提案ID到提案的映射
    mapping(uint => Proposal) public proposals;

    // 添加投票权重映射
    mapping(address => uint) public voteWeight;

    // 记录每个地址是否已经投票
    mapping(address => bool) public voters;

    // 添加角色控制 提案授权人
    mapping(address => bool) public proposers;

    // 添加合约拥有者
    address public owner;

    // 提案ID计数器
    uint public proposalCount;

    // 添加时间相关的状态变量
    uint public startTime;  // 投票开始时间
    uint public endTime;    // 投票结束时间

    // 事件：当有新提案创建时触发
    event ProposalCreated(uint proposalId, string description);

    // 事件：当有人投票时触发
    event Voted(uint proposalId, address voter, uint weight);

    // 添加时间检查修饰器
    modifier voteOpen() {
        require(block.timestamp >= startTime, unicode"投票还未开始");
        require(block.timestamp <= endTime, unicode"投票已结束");
        _;
    }

    // 添加修饰器
    modifier onlyOwner() {
        require(msg.sender == owner, unicode"只有合约拥有者可以调用此函数");
        _;
    }

    modifier onlyProposer() {
        require(proposers[msg.sender], unicode"只有授权提案人可以创建提案");
        _;
    }

    // 添加提案人管理函数
    function addProposer(address _proposer) public onlyOwner {
        proposers[_proposer] = true;
    }

    function removeProposer(address _proposer) public onlyOwner {
        proposers[_proposer] = false;
    }

    // 添加设置权重的函数
    function setVoteWeight(address _voter, uint _weight) public onlyOwner{
        // require(msg.sender == owner, unicode"只有合约拥有者可以设置权重");
        voteWeight[_voter] = _weight;
    }

    // 创建新提案
    function createProposal(string memory _description) public onlyProposer {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            description: _description,
            voteCount: 0,
            exists: true
        });

        emit ProposalCreated(proposalCount, _description);
    }

    // 投票给某个提案
    function vote(uint _proposalId) public voteOpen {
        require(proposals[_proposalId].exists, unicode"提案不存在");
        require(!voters[msg.sender], unicode"您已经投票");

        uint weight = voteWeight[msg.sender];
        if(weight == 0) weight = 1; // 默认权重为1

        proposals[_proposalId].voteCount += weight;
        voters[msg.sender] = true;

        emit Voted(_proposalId, msg.sender, weight);
    }

    // 查询某个提案的得票数
    function getVoteCount(uint _proposalId) public view returns (uint) {
        require(proposals[_proposalId].exists, "Proposal does not exist");
        return proposals[_proposalId].voteCount;
    }

    // 查询获胜提案的ID
    function getWinningProposal() public view returns (uint winningProposalId) {
        uint winningVoteCount = 0;

        for (uint i = 1; i <= proposalCount; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposalId = i;
            }
        }
    }

    // 获取某个提案的得票率
    function getVotePercentage(uint _proposalId) public view returns (uint) {
        require(proposals[_proposalId].exists, unicode"提案不存在");
        uint totalVotes = 0;
        
        for(uint i = 1; i <= proposalCount; i++) {
            totalVotes += proposals[i].voteCount;
        }
        
        if(totalVotes == 0) return 0;
        return (proposals[_proposalId].voteCount * 100) / totalVotes;
    }
}