// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "ERC721A/ERC721A.sol";
import {MerkleProof} from "openzeppelin/utils/cryptography/MerkleProof.sol";
import "openzeppelin/access/Ownable.sol";

contract ReceiptTicket is ERC721A, Ownable {
    // mint variables
    uint256 public TICKET_PRICE = 0.00777 ether;
    uint256 public WORM_FAN_TICKET_PRICE = 0.00333 ether;
    uint256 public MAX_WORM_FAN_MINTS = 3;
    bytes32 public merkleRoot;
    bool public canMint;
    uint256 public mintCloseTime;
    mapping(address => uint256) public wormFanMints;

    error MintClosed();
    error NotAWormFan();
    error IncorrectPrice();
    error WormFanMaxReached();
    error TooEarly();

    // drawing variables
    uint256 internal _lastDrawBlock;
    uint256 internal _currentWinnerIndex;
    address[14] public winners;

    error AllWinnersDrawn();
    error AlreadyPickedThisBlock();

    constructor() ERC721A("Receipt Ticket by @worm_emoji", "RCPT") {}

    // Internal utility functions

    function _mintOpen() internal view returns (bool) {
        return canMint && block.timestamp < mintCloseTime;
    }

    function _isAllowlisted(address _wallet, bytes32[] calldata _proof) internal view returns (bool) {
        return MerkleProof.verify(_proof, merkleRoot, keccak256(abi.encodePacked(_wallet)));
    }

    // Mint functions
    function mint(uint256 quantity) external payable {
        if (!_mintOpen()) {
            revert MintClosed();
        }

        if (msg.value != TICKET_PRICE * quantity) {
            revert IncorrectPrice();
        }
        _mint(msg.sender, quantity);
    }

    function mintWormFan(uint256 quantity, bytes32[] calldata proof) external payable {
        if (!_mintOpen()) {
            revert MintClosed();
        }

        if (msg.value != WORM_FAN_TICKET_PRICE * quantity) {
            revert IncorrectPrice();
        }

        if (!_isAllowlisted(msg.sender, proof)) {
            revert NotAWormFan();
        }

        if (wormFanMints[msg.sender] + quantity > MAX_WORM_FAN_MINTS) {
            revert WormFanMaxReached();
        }

        wormFanMints[msg.sender] += quantity;
        _mint(msg.sender, quantity);
    }

    function pickWinners() external {
        if (block.timestamp < mintCloseTime) revert TooEarly();
        if (_lastDrawBlock == block.number) revert AlreadyPickedThisBlock();
        if (_currentWinnerIndex == 14) revert AllWinnersDrawn();

        uint256 winner = getWinner();
        winners[_currentWinnerIndex] = ownerOf(winner);
        _lastDrawBlock = block.number;
        _currentWinnerIndex++;
    }

    function getWinner() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.basefee, block.difficulty, msg.sender))) % totalSupply();
    }

    // Admin functions
    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function setMintInfo(bool _canMint, uint256 _mintCloseTime) external onlyOwner {
        canMint = _canMint;
        mintCloseTime = _mintCloseTime;
    }

    function setPrices(uint256 _ticketPrice, uint256 _wormFanTicketPrice) external onlyOwner {
        TICKET_PRICE = _ticketPrice;
        WORM_FAN_TICKET_PRICE = _wormFanTicketPrice;
    }

    function setWormFanMaxMints(uint256 _maxMints) external onlyOwner {
        MAX_WORM_FAN_MINTS = _maxMints;
    }

    function withdraw() external onlyOwner {
        payable(this.owner()).transfer(address(this).balance);
    }
}
