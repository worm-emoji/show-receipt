// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "../ShowReceiptTokenURI.sol";

contract DeployReceiptTokenURI is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        new ShowReceiptTokenURI("ipfs://QmaqA2KheozY8BecooAZwyLeg7TTa9DUjNUUfGPvGVep5p");
        vm.stopBroadcast();
    }
}
