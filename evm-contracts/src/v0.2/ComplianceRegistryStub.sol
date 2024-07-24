// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IComplianceRegistryStub} from "./interfaces/IComplianceRegistryStub.sol";
import {IComplianceRegistry} from "./interfaces/IComplianceRegistry.sol";
import {ProposalCommon} from "./libraries/ProposalCommon.sol";

error ComplianceRegistryStub__InvalidConfirmProposalStatus();

contract ComplianceRegistryStub is IComplianceRegistryStub, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant PROPOSAL_MANAGEMENT_ROLE =
        keccak256("PROPOSAL_MANAGEMENT_ROLE");

    constructor(address _whitelistRegistry, address _blacklistRegistry) {
        _grantRole(ADMIN_ROLE, _msgSender());
        _setRoleAdmin(PROPOSAL_MANAGEMENT_ROLE, ADMIN_ROLE);

        whitelistRegistry = IComplianceRegistry(_whitelistRegistry);
        blacklistRegistry = IComplianceRegistry(_blacklistRegistry);
    }

    IComplianceRegistry public whitelistRegistry;
    IComplianceRegistry public blacklistRegistry;

    function confirmProposal(
        ProposalCommon.Proposal memory proposal
    ) external override onlyRole(PROPOSAL_MANAGEMENT_ROLE) {
        if (proposal.status != ProposalCommon.ProposalStatus.Approved)
            revert ComplianceRegistryStub__InvalidConfirmProposalStatus();
        if (proposal.isWhitelist) {
            whitelistRegistry.addProposalToList(proposal);
            emit AddToWhitelist(proposal.id);

            _revokeCompliance(proposal, blacklistRegistry);
        } else {
            blacklistRegistry.addProposalToList(proposal);
            emit AddToBlacklist(proposal.id);

            _revokeCompliance(proposal, whitelistRegistry);
        }
    }

    function _revokeCompliance(
        ProposalCommon.Proposal memory proposal,
        IComplianceRegistry _registry
    ) internal {
        for (uint256 idx = 0; idx < proposal.targetAddresses.length; idx++) {
            address target = proposal.targetAddresses[idx];
            if (_registry.checkAddress(target)) {
                _registry.revokeCompliance(
                    target,
                    proposal.author,
                    proposal.id
                );
            }
        }
    }

    function isWhitelist(
        address account
    ) external view override returns (bool) {
        return
            whitelistRegistry.checkAddress(account) &&
            !blacklistRegistry.checkAddress(account);
    }

    function isBlacklist(
        address account
    ) external view override returns (bool) {
        return blacklistRegistry.checkAddress(account);
    }
}
