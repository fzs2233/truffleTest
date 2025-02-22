// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Voting {
    // 投票提案结构
    struct Proposal {
        string description; // 提案描述
        uint voteCount;     // 得票数
        bool exists;       // 是否存在,这个是因为mapping类型在key不存在时会返回默认值，所以需要一个变量来判断是否存在  
    }

    // 提案ID到提案的映射
    mapping(uint => Proposal) public proposals;

    // 记录每个地址是否已经投票
    mapping(address => bool) public voters;

    // 提案ID计数器
    uint public proposalCount;

    // 事件：当有新提案创建时触发
    event ProposalCreated(uint proposalId, string description);

    // 事件：当有人投票时触发
    event Voted(uint proposalId, address voter);

    // 创建新提案
    function createProposal(string memory _description) public {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            description: _description,
            voteCount: 0,
            exists: true
        });

        emit ProposalCreated(proposalCount, _description);
    }

    // 投票给某个提案
    function vote(uint _proposalId) public {
        require(proposals[_proposalId].exists, "Proposal does not exist");
        require(!voters[msg.sender], "You have already voted");

        proposals[_proposalId].voteCount++;
        voters[msg.sender] = true;

        emit Voted(_proposalId, msg.sender);
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
}