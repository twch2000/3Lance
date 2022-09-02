import { ethers } from "hardhat";

async function main() {
  

  const ERC20 = await ethers.getContractFactory("ERC20");
  const erc20 = await ERC20.deploy("Hello Token", "HEL");

  await erc20.deployed();

  console.log("ERC20 deployed to:", erc20.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
