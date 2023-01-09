import { ethers } from "hardhat";

export async function deployContracts() {
  const MRC = await ethers.getContractFactory("MRCRYPTO");
  const mrcContract = await MRC.deploy(
    "MrCryptoMock",
    "MRC",
    "https://apinft.racksmafia.com/api/",
    "https://apinft.racksmafia.com/api/hidden.json",
  );

  await mrcContract.deployed();

  console.log("MRC deployed to:", mrcContract.address);

  const E7L = await ethers.getContractFactory("E7LBasic");
  const e7lContract = await E7L.deploy("E7L", "E7L", mrcContract.address);

  await e7lContract.deployed();

  console.log("E7L deployed to:", e7lContract.address);

  return { mrcContract, e7lContract };
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
deployContracts().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
