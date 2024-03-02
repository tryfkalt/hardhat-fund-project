const { network, deployments } = require("hardhat");
const { networkConfig } = require("../helper-hardhat-config");
const { developmentChains } = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");

// function deployFunc() {
//     console.log('Deploying FundMe contract...');
//     hre.getNamedAccounts()
//     hre.deployments
// }

// module.exports.default = deployFunc;
// same as:
// module.exports = async (hre) => {
//     // Get 2 variables from hre, getNamedAccounts and deployments
//     // getNameAccounts is a function that returns the named accounts from the network
//     // deployments is an object that contains the deploy function to deploy contracts
//   const { getNamedAccounts, deployments } = hre;
// };
// same as:

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;

  // const ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"];
  let ethUsdPriceFeedAddress;
  if (developmentChains.includes(network.name)) {
    const ethUsdAggregator = await deployments.get("MockV3Aggregator");
    ethUsdPriceFeedAddress = ethUsdAggregator.address;
  } else {
    ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"];
  }
  // if the contract does not exist, we deploy a minimal version of it for our local testing

  //when going for localhost or hardhat network we want to use a mock
  const fundMe = await deploy("FundMe", {
    from: deployer,
    args: [ethUsdPriceFeedAddress], // put price feed address
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  });

  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    await verify(fundMe.address, [ethUsdPriceFeedAddress]);
  }

  log("----------------------------");
  log(`Contract deployed! `);
};
module.exports.tags = ["all", "fundme"];
