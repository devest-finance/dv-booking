// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;


import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@devest/contracts/DvFactory.sol";
import "./DvBooking.sol";

contract DvBookingFactory is DvFactory {

    constructor(){
        _owner = _msgSender();
    }

    /**
     * @dev detach a token from this factory
     */
    function detach(address payable _tokenAddress) external payable onlyOwner {
        DvBooking token = DvBooking(_tokenAddress);
        token.detach();
    }

    function issue(address _tokenAddress, string memory tokenURI, string memory name, string memory symbol) public payable isActive returns (address)
    {
        // take royalty
        require(msg.value >= _issueFee, "Please provide enough fee");
        if (_issueFee > 0)
            payable(_feeRecipient).transfer(_issueFee);

        // issue token
        DvBooking token = new DvBooking(_tokenAddress, tokenURI, name, symbol, address(this), _msgSender());

        emit deployed(_msgSender(), address(token));
        return address(token);
    }


}
