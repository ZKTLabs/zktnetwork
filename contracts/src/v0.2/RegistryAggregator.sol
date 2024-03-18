// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./WriteAccessControl.sol";
import "./interfaces/IComplianceRegistry.sol";

error RegistryAggregator__Contradiction();


contract RegistryAggregator is IComplianceRegistry, WriteAccessControl {
    struct ComplianceProposal {
        bool isWhitelist;
        bool isBlacklist;
        bytes32 proposal;
        string speaker;
        uint256 updatedAt;
    }

    mapping(address => bool) public whitelist;
    mapping(address => bool) public blacklist;
    mapping(bytes32 => ComplianceProposal) public proposalRecord;

    function submit(
        address account,
        bool isWhitelist,
        bool isBlacklist,
        bytes32 calldata proposalId,
        string calldata speaker
    )
        external
        onlyAccess
    {
        if ((isWhitelist && isBlacklist) || (!isWhitelist && !isBlacklist))
            revert RegistryAggregator__Contradiction();
        if (isWhitelist) whitelist[account] = true;
        else if (isBlacklist) {
            whitelist[account] = false; // double check or revoke
            blacklist[account] = true;
        }
        proposalRecord[proposalId] = ComplianceProposal({
            isWhitelist: isWhitelist,
            isBlacklist: isBlacklist,
            proposal: proposalId,
            speaker: speaker,
            updatedAt: block.timestamp
        });

    }


    function isWhitelist(address account) external override view returns (bool) {
        return whitelist[account] && !blacklist[account];
    }

    function isBlacklist(address account) external override view returns (bool) {
        return blacklist[account];
    }
}
