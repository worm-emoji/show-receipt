// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {ReceiptTicket} from "./ReceiptTicket.sol";
import {ShowReceipt} from "./ShowReceipt.sol";
import {DSTest} from "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import "forge-std/console.sol";

contract ReceiptTicketTest is DSTest {
    ReceiptTicket internal ticket;
    ShowReceipt internal receipt;
    Vm internal immutable vm = Vm(HEVM_ADDRESS);
    address[] internal users;
    bytes32 internal nextUser = keccak256(abi.encodePacked("user address"));

    function getNextUserAddress() external returns (address payable) {
        //bytes32 to address conversion
        address payable user = payable(address(uint160(uint256(nextUser))));
        nextUser = keccak256(abi.encodePacked(nextUser));
        return user;
    }

    function setUp() public {
        receipt = new ShowReceipt("");
        ticket = new ReceiptTicket("", address(receipt), 0x00);
        receipt.setApprovalForAll(address(ticket), true);
        ticket.setMintInfo(true, block.timestamp + 1000);
        users = new address[](100);
        for (uint256 i = 0; i < 100; i++) {
            address payable user = this.getNextUserAddress();
            vm.deal(user, 100 ether);
            users[i] = user;
            vm.prank(users[i]);
            ticket.mint{value: ticket.TICKET_PRICE()}(1);
        }
    }

    function testMint() public {
        vm.prank(users[0]);
        ticket.mint{value: ticket.TICKET_PRICE()}(1);
    }

    function testPickWinner() public {
        vm.warp(block.timestamp + 1000);
        ticket.pickWinner();
    }

    function testFailPickWinners() public {
        // Fails because you can't pick more than one winner in same block
        vm.warp(block.timestamp + 1000);

        for (uint256 i = 0; i < 14; i++) {
            ticket.pickWinner();
        }
    }

    function testPickWinners() public {
        vm.warp(block.timestamp + 1000);

        for (uint256 i = 0; i < 14; i++) {
            vm.warp(block.timestamp + 12);
            vm.difficulty(i + 1);
            vm.roll(block.number + 1);
            ticket.pickWinner();
        }
    }
}
