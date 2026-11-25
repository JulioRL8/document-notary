// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {DocumentNotary} from "../src/DocumentNotary.sol";
import {TestBase} from "./TestBase.sol";

contract DocumentNotaryTest is TestBase {
    DocumentNotary private notary;
    bytes32 private constant DIGEST = keccak256("lease.pdf");
    event Registered(address indexed author, bytes32 indexed digest, uint256 timestamp);

    function setUp() public {
        notary = new DocumentNotary();
    }

    function testRegistrationIsScopedToAuthor() public {
        vm.warp(100);
        vm.expectEmit(true, true, false, true, address(notary));
        emit Registered(address(this), DIGEST, 100);
        notary.register(DIGEST);

        address anotherAuthor = address(0xA11CE);
        (bool exists,) = notary.entries(anotherAuthor, DIGEST);
        assertTrue(!exists);

        vm.warp(200);
        vm.prank(anotherAuthor);
        notary.register(DIGEST);

        (bool first, uint256 firstTimestamp) = notary.entries(address(this), DIGEST);
        (bool second, uint256 secondTimestamp) = notary.entries(anotherAuthor, DIGEST);
        assertTrue(first && second);
        assertEq(firstTimestamp, 100);
        assertEq(secondTimestamp, 200);
    }

    function testRejectsEmptyDigest() public {
        vm.expectRevert(DocumentNotary.EmptyDigest.selector);
        notary.register(bytes32(0));
    }

    function testRejectsRepeatBySameAuthor() public {
        notary.register(DIGEST);
        vm.expectRevert(DocumentNotary.AlreadyRegistered.selector);
        notary.register(DIGEST);
    }

    function testFuzzRecordsDigest(bytes32 digest) public {
        vm.assume(digest != bytes32(0));
        notary.register(digest);
        (bool exists, uint256 timestamp) = notary.entries(address(this), digest);
        assertTrue(exists);
        assertEq(timestamp, block.timestamp);
    }
}
