const { getNamedAccounts } = require("hardhat");

async function main() {
  const deployer = await getNamedAccounts();
  const myContract = await deployments.get("FundMe");
  const fundMe = await ethers.getContractAt(myContract.abi, myContract.address);
  console.log("Funding...");
  const transactionResponse = await fundMe.withdraw();
  await transactionResponse.wait(1);
  console.log("Withdraw success!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
