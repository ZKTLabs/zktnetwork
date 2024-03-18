// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IComplianceRegistry.sol";

error ComplianceChecker__OnlyWhitelistAddress();
error ComplianceChecker__IsBlacklistAddress();


abstract contract ComplianceChecker {
    IComplianceRegistry private registry;

    constructor(IComplianceRegistry _registry) {
        registry = _registry;
    }

    modifier onlyWhitelistAction(address sender) {
        if (!registry.isWhitelist(sender)) revert ComplianceChecker__OnlyWhitelistAddress();
        _;
    }

    modifier onlyExcludeBlacklistAction(address sender) {
        if (registry.isBlacklist(sender)) revert ComplianceChecker__IsBlacklistAddress();
        _;
    }
}
