// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "../ReceiptTicket.sol";
import "../ShowReceipt.sol";

contract DeployReceiptTickets is Script {
    uint256 public holdersCount = 113;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address[] memory holders = new address[](holdersCount);

        for (uint256 i = 0; i < holdersCount; i++) {
            string memory line = vm.readLine("./holders.txt");
            holders[i] = vm.parseAddress(line);
            console.log(vm.parseAddress(line));
        }

        vm.startBroadcast(deployerPrivateKey);
        ShowReceipt receipt = new ShowReceipt("ipfs://QmaqA2KheozY8BecooAZwyLeg7TTa9DUjNUUfGPvGVep5p/");
        ReceiptTicket ticket =
        new ReceiptTicket("ipfs://QmRWJUvR3YVF8bWHtpquaqgWUKMCGA7z9msVnDuFYUBuLu", address(receipt), 0x24ec4658b186699b16c8ff07d4a73101463553a3b5d0bb6c1c34fc7ebb0bb794);
        ticket.airdrop(holders);
        receipt.setApprovalForAll(address(ticket), true);
        ticket.setMintInfo(true, block.timestamp + 172800); // 48 hours
        vm.stopBroadcast();
    }
}
