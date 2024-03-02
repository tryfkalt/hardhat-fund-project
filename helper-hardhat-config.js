const networkConfig = {
  11155111: {
    name: "sepolia",
    ethUsdPriceFeed: "0x779877A7B0D9E8603169DdbD7836e478b4624789",
  },
  137: {
    name: "polygon",
    ethUsdPriceFeed: "0xF9680D99D6C9589e2a93a78A04A279e509205945",
  },
};

const developmentChains = ["hardhat", "localhost"];
const DECIMALS = 8;
const INITIAL_ANSWER = 200000000000;

module.exports = { networkConfig, developmentChains, DECIMALS, INITIAL_ANSWER };
