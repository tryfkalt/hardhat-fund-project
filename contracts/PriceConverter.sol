// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed) internal  view returns(uint256){
        // ABI via interface
        // // Address of the contract we want to interact with outside our contract == external contract 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (,int256 price,,,) = priceFeed.latestRoundData(); // by using commas ,,, we actually don't use/store the values returned for the rest of the returning values of the function
        // priceFeed variable of AggregatorV3Interface type contract
        // price = ETH in terms of USD
        return uint256(price * 1e10); // that is because price is 3e8 and the msg.value has 18 zeros so the units do not match. Also we typecast to have the same type

    }
    
    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256){
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd= (ethPrice * ethAmount) / 1e18; 
        return ethAmountInUsd;
    }
    // get the price of eth -> usd
}