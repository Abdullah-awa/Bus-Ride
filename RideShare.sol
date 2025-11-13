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
 uint256 public nextRideId;
    mapping(uint256 => Ride) public rides;

    // Events
    event RideRequested(uint256 indexed rideId, address indexed passenger, uint256 fareWei);
    event RideAccepted(uint256 indexed rideId, address indexed operator);
    event RideCompleted(uint256 indexed rideId);
    event RideCancelled(uint256 indexed rideId);
    event OperatorWithdrawn(uint256 indexed rideId, address indexed operator, uint256 amount);

    // Modifiers
    modifier onlyPassenger(uint256 _rideId) {
        require(msg.sender == rides[_rideId].passenger, "Only passenger");
        _;
    }

    modifier onlyOperator(uint256 _rideId) {
        require(msg.sender == rides[_rideId].operator, "Only operator");
        _;
    }

    /// @notice Passenger requests a ride and deposits fare
    /// @param _operator operator address that will accept the ride
    function requestRide(address payable _operator) external payable returns (uint256) {
        require(msg.value > 0, "Fare must be > 0");
        uint256 rideId = nextRideId++;
        rides[rideId] = Ride({
            id: rideId,
            passenger: payable(msg.sender),
            operator: _operator,
            fareWei: msg.value,
            status: Status.Requested,
            operatorWithdrawn: false
        });
        emit RideRequested(rideId, msg.sender, msg.value);
        return rideId;
    }
     /// @notice Operator accepts the ride
   function acceptRide(uint256 _rideId) external {
    Ride storage r = rides[_rideId];
    require(r.status == Status.Requested, "Ride not requested");
    require(msg.sender == r.operator, "Only designated operator can accept");
    r.status = Status.Accepted;
    emit RideAccepted(_rideId, msg.sender);
}


    /// @notice Operator marks ride as completed
    function completeRide(uint256 _rideId) external onlyOperator(_rideId) {
        Ride storage r = rides[_rideId];
        require(r.status == Status.Accepted, "Ride must be accepted");
        r.status = Status.Completed;
        emit RideCompleted(_rideId);
    }

    /// @notice Passenger cancels a requested ride before acceptance
    function cancelRide(uint256 _rideId) external onlyPassenger(_rideId) {
        Ride storage r = rides[_rideId];
        require(r.status == Status.Requested, "Only pending rides can be cancelled");
        r.status = Status.Cancelled;
        // Refund passenger
        uint256 amount = r.fareWei;
        r.fareWei = 0;
        (bool sent, ) = r.passenger.call{value: amount}("");
        require(sent, "Refund failed");
        emit RideCancelled(_rideId);
    }


}
