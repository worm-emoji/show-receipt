// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {ReceiptTicket} from "../ReceiptTicket.sol";
import {DSTest} from "ds-test/test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {Vm} from "forge-std/Vm.sol";

contract ShadowBeaconTest is DSTest {
    ShadowBeacon internal beacon;
    Vm internal immutable vm = Vm(HEVM_ADDRESS);
    address signer = address(1234);

    function setUp() public {
        beacon = new ShadowBeacon(signer, "");
        vm.prank(signer, signer);
        beacon.transferFrom(address(0), address(1), 1);
    }

}