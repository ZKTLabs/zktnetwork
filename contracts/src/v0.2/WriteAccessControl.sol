// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

error WriteAccessControl__AccessDenied();
error WriteAccessControl__PermissionDenied();
error WriteAccessControl__AlreadyGrantPermission();
error WriteAccessControl__AlreadyRevokePermission();

contract WriteAccessControl {

    address private owner;
    mapping(address => bool) internal accessList;

    event AddedAccess(address indexed account);
    event RemovedAccess(address indexed account);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyAccess() {
        if (!accessList[msg.sender]) revert WriteAccessControl__AccessDenied();
        _;
    }

    function addAccess(address account) external {
        if (msg.sender != owner) revert WriteAccessControl__PermissionDenied();
        if (accessList[account]) revert WriteAccessControl__AlreadyGrantPermission();
        accessList[account] = true;
        emit AddedAccess(account);
    }

    function removeAccess(address account) external {
        if (msg.sender != owner) revert WriteAccessControl__PermissionDenied();
        if (!accessList[account]) revert WriteAccessControl__AlreadyRevokePermission();
        accessList[account] = false;
        emit RemovedAccess(account);
    }
}
