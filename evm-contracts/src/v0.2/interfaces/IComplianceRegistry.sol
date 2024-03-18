// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IComplianceRegistry {
    function isWhitelist(address account) external view returns (bool);

    function isBlacklist(address account) external view returns (bool);
}
