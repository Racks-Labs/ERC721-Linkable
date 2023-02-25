import { ethers } from "hardhat";
import { deployBasic } from "./deployBasic";

export async function deployE7LManager() {
  const { E7L, MRC, jommys, yonathan } = await deployBasic();

  const E7LManager_Factory = await ethers.getContractFactory("E7LManager");
  const E7LManager = await E7LManager_Factory.connect(jommys).deploy();

  await E7L.connect(yonathan).mint(1);
  await E7L.connect(yonathan).mint(2);
  await E7L.connect(yonathan).setApprovalForAll(E7LManager.address, true);

  return { E7L, MRC, E7LManager, jommys, yonathan };
}
