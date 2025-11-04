// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Simple Ride Escrow Contract for Bus Rides
/// @notice Demonstrates sender (passenger), receiver (operator) and blockchain as middle layer
contract RideShare {
    enum Status { Requested, Accepted, Completed, Cancelled }

    struct Ride {
        uint256 id;
        address payable passenger;
        address payable operator;
        uint256 fareWei; // fare in wei
        Status status;
        bool operatorWithdrawn;
    }

}