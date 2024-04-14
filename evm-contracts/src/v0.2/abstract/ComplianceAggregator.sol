// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../interfaces/IComplianceRegistryStub.sol";

error ComplianceAggregator__OnlyWhitelistAction();
error ComplianceAggregator__ExcludeBlacklistAction();

abstract contract ComplianceAggregator {

    modifier onlyWhitelistAction() {
        if (!stub.isWhitelist(tx.origin))
            revert ComplianceAggregator__OnlyWhitelistAction();
        _;
    }

    modifier ExcludeBlacklistAction() {
        if (stub.isBlacklist(tx.origin))
            revert ComplianceAggregator__ExcludeBlacklistAction();
        _;
    }

    IComplianceRegistryStub public stub;

    constructor(address complianceRegistryStub) {
        stub = IComplianceRegistryStub(complianceRegistryStub);
    }
}
