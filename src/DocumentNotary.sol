// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

contract DocumentNotary {
    error EmptyDigest();
    error AlreadyRegistered();

    struct Entry {
        bool exists;
        uint256 timestamp;
    }

    mapping(address author => mapping(bytes32 digest => Entry)) public entries;

    event Registered(address indexed author, bytes32 indexed digest, uint256 timestamp);

    function register(bytes32 digest) external {
        if (digest == bytes32(0)) revert EmptyDigest();
        if (entries[msg.sender][digest].exists) revert AlreadyRegistered();

        entries[msg.sender][digest] = Entry(true, block.timestamp);
        emit Registered(msg.sender, digest, block.timestamp);
    }
}
