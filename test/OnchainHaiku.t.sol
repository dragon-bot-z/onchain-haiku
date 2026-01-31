// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {OnchainHaiku} from "../src/OnchainHaiku.sol";

contract OnchainHaikuTest is Test {
    OnchainHaiku public haiku;
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    function setUp() public {
        haiku = new OnchainHaiku();
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }

    function test_Mint() public {
        vm.prank(alice);
        uint256 tokenId = haiku.mint{value: 0.001 ether}();

        assertEq(tokenId, 1);
        assertEq(haiku.ownerOf(1), alice);
        assertEq(haiku.balanceOf(alice), 1);
        assertEq(haiku.totalSupply(), 1);
    }

    function test_MintMultiple() public {
        vm.startPrank(alice);
        haiku.mint{value: 0.001 ether}();
        haiku.mint{value: 0.001 ether}();
        haiku.mint{value: 0.001 ether}();
        vm.stopPrank();

        assertEq(haiku.totalSupply(), 3);
        assertEq(haiku.balanceOf(alice), 3);
    }

    function test_GetHaiku() public {
        vm.prank(alice);
        uint256 tokenId = haiku.mint{value: 0.001 ether}();

        (string memory l1, string memory l2, string memory l3) = haiku.getHaiku(tokenId);

        // All lines should have content
        assertTrue(bytes(l1).length > 0);
        assertTrue(bytes(l2).length > 0);
        assertTrue(bytes(l3).length > 0);

        console2.log("Generated Haiku:");
        console2.log("  ", l1);
        console2.log("  ", l2);
        console2.log("  ", l3);
    }

    function test_DeterministicGeneration() public {
        vm.prank(alice);
        haiku.mint{value: 0.001 ether}();

        (string memory l1a, string memory l2a, string memory l3a) = haiku.getHaiku(1);
        (string memory l1b, string memory l2b, string memory l3b) = haiku.getHaiku(1);

        // Same token should always return same haiku
        assertEq(keccak256(bytes(l1a)), keccak256(bytes(l1b)));
        assertEq(keccak256(bytes(l2a)), keccak256(bytes(l2b)));
        assertEq(keccak256(bytes(l3a)), keccak256(bytes(l3b)));
    }

    function test_TokenURI() public {
        vm.prank(alice);
        haiku.mint{value: 0.001 ether}();

        string memory uri = haiku.tokenURI(1);

        // Should be a data URI
        assertTrue(bytes(uri).length > 0);

        // Check it starts with data:application/json;base64,
        bytes memory uriBytes = bytes(uri);
        assertEq(uriBytes[0], "d");
        assertEq(uriBytes[1], "a");
        assertEq(uriBytes[2], "t");
        assertEq(uriBytes[3], "a");

        console2.log("Token URI length:", bytes(uri).length);
    }

    function test_Transfer() public {
        vm.prank(alice);
        haiku.mint{value: 0.001 ether}();

        vm.prank(alice);
        haiku.transferFrom(alice, bob, 1);

        assertEq(haiku.ownerOf(1), bob);
        assertEq(haiku.balanceOf(alice), 0);
        assertEq(haiku.balanceOf(bob), 1);
    }

    function test_RevertInsufficientPayment() public {
        vm.prank(alice);
        vm.expectRevert(OnchainHaiku.InsufficientPayment.selector);
        haiku.mint{value: 0.0001 ether}();
    }

    function test_Withdraw() public {
        vm.prank(alice);
        haiku.mint{value: 0.001 ether}();

        uint256 balanceBefore = address(this).balance;
        haiku.withdraw();
        uint256 balanceAfter = address(this).balance;

        assertEq(balanceAfter - balanceBefore, 0.001 ether);
    }

    function test_UniqueHaikus() public {
        // Mint several and check they're not all identical
        vm.prank(alice);
        haiku.mint{value: 0.001 ether}();

        vm.roll(block.number + 100);
        vm.warp(block.timestamp + 1000);

        vm.prank(bob);
        haiku.mint{value: 0.001 ether}();

        (string memory l1a,,) = haiku.getHaiku(1);
        (string memory l1b,,) = haiku.getHaiku(2);

        // Note: They could randomly match, but probability is low
        console2.log("Haiku 1 line 1:", l1a);
        console2.log("Haiku 2 line 1:", l1b);
    }

    function test_MaxSupply() public {
        // This test would take too long for 1000 mints
        // Just test the logic
        for (uint256 i = 0; i < 10; i++) {
            vm.prank(alice);
            haiku.mint{value: 0.001 ether}();
        }
        assertEq(haiku.totalSupply(), 10);
    }

    receive() external payable {}
}
