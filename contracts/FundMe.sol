// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PriceConverter.sol";

error FundMe__NotOwner();

/// @title A contract for crowd funding
/// @author Tryfon Kaltapanadis
/// @notice This contract is to demo a sample funding contract
/// @dev This implements price feeds as our library
contract FundMe {
  using PriceConverter for uint256;

  uint256 public constant MINIMUM_USD = 50 * 1e18; // as it doesn't change anywhere we store is a constant to save gas

  address[] private s_funders;
  mapping(address => uint256) private s_addressToAmountFunded;

  address private immutable i_owner;

  AggregatorV3Interface public s_priceFeed;

  modifier onlyOwner() {
    // require(msg.sender == i_owner, "Unauthorized User");
    if (msg.sender != i_owner) {
      revert FundMe__NotOwner();
    } // its the same as require but more gas efficient
    _; // first check the require and THEN do the rest of the code _;
  }

  // constructor is called imidiatelly when deploying a contract
  constructor(address priceFeedAdress) {
    i_owner = msg.sender;
    s_priceFeed = AggregatorV3Interface(priceFeedAdress);
  }

  receive() external payable {
    fund();
  }

  fallback() external payable {
    fund();
  }

  /// @notice A function to fund the contract
  // in order to declare a payable function where you can pay we use payable -- smart contracts can hold funds like wallets
  function fund() public payable {
    // Want to be able to set a minimum fund amount in USD
    require(
      msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
      "Didn't send enough funds."
    ); // 1e18 == 1 * 10 ** 18 = 10000000000000000000 wei = 1 eth
    // if require condition is not met then revert with error message
    // revert = undo any action before, and send remaining gas back
    // msg.value.getConversionRate() is the same as getConversionRate(msg.value) and the 1st arg is the msg.value
    // if the function had 2 args then msg.value.getConversionRate(a) --> msg.value is 1st and a is 2nd
    s_funders.push(msg.sender);
    s_addressToAmountFunded[msg.sender] = msg.value;
  }

  function withdraw() public onlyOwner {
    // require(msg.sender == owner, "Unauthorized User");

    for (
      uint256 funderIndex = 0;
      funderIndex < s_funders.length;
      funderIndex++
    ) {
      address funder = s_funders[funderIndex];
      s_addressToAmountFunded[funder] = 0;
    }
    // reset array
    s_funders = new address[](0); // make funders a new array with zero elements to start
    // withdraw funds 3 ways to do it

    // // transfer
    // // msg.sender = address -- payable (msg.sender) = payable address
    // payable(msg.sender).transfer(address(this).balance); // fails throws error
    // // send
    // bool sendSuccess = payable(msg.sender).send(address(this).balance);    // if fails return bool
    // require(sendSuccess, "send failed");

    // call
    (bool callSuccess, ) = payable(msg.sender).call{
      value: address(this).balance
    }("");
    require(callSuccess, "Call failed");
  }

  function cheaperWithdraw() public payable onlyOwner {
    address[] memory funders = s_funders;
    // mappings can't be in memory
    for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
      address funder = funders[funderIndex];
      s_addressToAmountFunded[funder] = 0;
    }
    s_funders = new address[](0);
    // call
    (bool callSuccess, ) = i_owner.call{value: address(this).balance}("");
    require(callSuccess, "Call failed");
  }

  function getOwner() public view returns (address) {
    return i_owner;
  }

  function getFunder(uint256 index) public view returns (address) {
    return s_funders[index];
  }

  function getAddressToAmountFunded(
    address funder
  ) public view returns (uint256) {
    return s_addressToAmountFunded[funder];
  }

  function getPriceFeed() public view returns (AggregatorV3Interface) {
    return s_priceFeed;
  }
}
