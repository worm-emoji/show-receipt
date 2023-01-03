// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "openzeppelin/proxy/ERC1967/ERC1967Proxy.sol";
import "../ReceiptTicket.sol";
import "../ShowReceipt.sol";

contract DeployReceiptTickets is Script {
    uint256 public holdersCount = 108;

    function run() public {
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address[] memory holders = new address[](holdersCount);

        for (uint256 i = 0; i < holdersCount; i++) {
            string memory line = vm.readLine("./holders.txt");
            holders[i] = vm.parseAddress(line);
            console.log(vm.parseAddress(line));
        }

        vm.startBroadcast(0x9aaC8cCDf50dD34d06DF661602076a07750941F6);
        ShowReceipt receipt = new ShowReceipt("");
        ReceiptTicket ticket = new ReceiptTicket("", address(receipt));
        ticket.airdrop(holders);
        receipt.setApprovalForAll(address(ticket), true);
        ticket.setMintInfo(true, block.timestamp + 60);
        vm.stopBroadcast();
    }
}
