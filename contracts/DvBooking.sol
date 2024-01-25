// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@devest/contracts/DeVest.sol";

contract DvBooking is Context, DeVest, ReentrancyGuard {

    event booked(address indexed customer, string[] dates);

    mapping(string => bool) public bookedDates;

    // Vesting / Trading token reference
    IERC20 internal _token;

    // Properties
    string internal _name;           // name of the tangible
    string internal _symbol;         // symbol of the tangible
    string internal _tokenURI;   // total supply of shares (10^decimals)
    uint256 public _totalSupply = 10000;

    uint256 private _price;
    uint256 private bookingPrice;

    constructor(address _tokenAddress, string memory __name, string memory __symbol, string memory __tokenURI, address _factory, address _owner) DeVest(_owner, _factory) {
        _token =  IERC20(_tokenAddress);
        _symbol = string(abi.encodePacked("nights ", __symbol));
        _name = __name;
        _tokenURI = __tokenURI;
    }

    /**
     *  Initialize TST as tangible
     */
    function initialize(uint tax, uint256 price) public onlyOwner nonReentrant virtual{
        require(tax >= 0 && tax <= 1000, 'Invalid tax value');
        _price = price;

        // set attributes
        _setRoyalties(tax, owner());
    }

    function book(string[] calldata dates) external takeFee payable {
        require(msg.value == bookingPrice * ( dates.length - 1), "Incorrect funds provided");
        // check if enough escrow allowed and pick the cash
        bookingPrice = (dates.length - 1) * _price;
        __allowance(_msgSender(), bookingPrice);
        _token.transferFrom(_msgSender(), address(this), bookingPrice);

        for (uint256 i = 0; i < dates.length; i++) {
            require(!bookedDates[dates[i]], "Date is already booked");
            bookedDates[dates[i]] = true;
        }
        emit booked(msg.sender, dates);
    }

    function isDateBooked(string calldata date) external view returns (bool) {
        return bookedDates[date];
    }

   /**
     *  Withdraw tokens from purchases from this contract
    */
    function withdraw() external onlyOwner {
        _token.transfer(_owner, _token.balanceOf(address(this)));
    }

    // set dates as unavailable, only owner
    function setUnavailable(string[] calldata dates) external onlyOwner {
        for (uint256 i = 0; i < dates.length; i++) {
            require(!bookedDates[dates[i]], "Date is already booked");
            bookedDates[dates[i]] = true;
        }
        emit booked(_owner, dates);
    }

    /**
     *  Internal token allowance
     */
    function __allowance(address account, uint256 amount) internal view {
        require(_token.allowance(account, address(this)) >= amount, 'Insufficient allowance provided');
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
