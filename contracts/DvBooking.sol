// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@devest/contracts/DeVest.sol";
import "@devest/contracts/VestingToken.sol";

contract DvBooking is Context, DeVest, VestingToken, ReentrancyGuard {

    struct Booking {
        uint checkIn;
        uint checkOut;
        address user;
    }

    Booking[] public bookings;

    event booked(address indexed from, uint256 checkIn, uint256 checkOut);

    mapping(string => bool) public bookedDates;

    // Properties
    string internal _name;           // name of the tangible
    string internal _symbol;         // symbol of the tangible
    string internal _tokenURI;   // total supply of shares (10^decimals)
    uint256 public _totalSupply = 10000;

    uint256 private _price;
    uint256 private bookingPrice;

    constructor(address _tokenAddress, string memory __name, string memory __symbol, string memory __tokenURI, address _factory, address _owner) DeVest(_owner, _factory) VestingToken(_tokenAddress) {
        _symbol = string(abi.encodePacked("nights ", __symbol));
        _name = __name;
        _tokenURI = __tokenURI;
    }

    /**
     *  Initialize TST as tangible
     */
    function initialize(uint tax, uint256 price) public onlyOwner nonReentrant virtual {
        require(tax >= 0 && tax <= 1000, 'Invalid tax value');
        _price = price;

        // set attributes
        _setRoyalties(tax, owner());
    }

    function book(uint256 _checkIn, uint256 _checkOut) external takeFee payable {
        require(_checkOut > _checkIn, "Check-out must be after check-in");
        uint numNights = (_checkOut - _checkIn) / 86400; // Calculate nights based on timestamps
        require(msg.value == numNights * _price, "Incorrect payment amount");

        for (uint i = 0; i < bookings.length; i++) {
            bool isOverlapping = (_checkIn < bookings[i].checkOut) && (_checkOut > bookings[i].checkIn);
            require(!isOverlapping, "Dates are not available");
        }

        bookings.push(Booking(_checkIn, _checkOut, msg.sender));
        emit booked(msg.sender, _checkIn, _checkOut);
    }

    function getAllBookings() external view returns (Booking[] memory) {
        return bookings;
    }

    function isDateBooked(uint256 _checkIn, uint256 _checkOut) public view returns (bool) {
        for (uint i = 0; i < bookings.length; i++) {
            bool isOverlapping = (_checkIn < bookings[i].checkOut) && (_checkOut > bookings[i].checkIn);
            if (isOverlapping) {
                return true; // Indicates there is an overlap, hence the date is booked.
            }
        }
        return false; // No overlapping bookings found.
    }

   /**
     *  Withdraw tokens from purchases from this contract
    */
    function withdraw() external onlyOwner {
        __transfer(_owner, __balanceOf(address(this)));
    }

    /**
    * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 /*tokenId*/) external view returns (string memory){
        return _tokenURI;
    }

    function supportsInterface(bytes4 /*interfaceId*/) external pure returns (bool){
        return false;
    }

    function getPrice() external view returns (uint256) {
        return _price;
    }

    function getTotalSupply() external view returns (uint256) {
        return _totalSupply;
    }
}
