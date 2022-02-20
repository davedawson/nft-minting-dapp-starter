const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  const Minter = await hre.ethers.getContractFactory("ButtsOnChain");
  const minter = await Minter.deploy(deployer.address);
  await minter.deployed();
  console.log("Minter deployed to:", minter.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
