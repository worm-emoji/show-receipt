// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "../ShowReceiptTokenURI.sol";

contract DeployReceiptTokenURI is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        new ShowReceiptTokenURI("ipfs://QmQY775pGMKGchRQ6bR7wJsPMUEkvEVmyn7Rfx813tLDWw/");
        vm.stopBroadcast();
    }
}
