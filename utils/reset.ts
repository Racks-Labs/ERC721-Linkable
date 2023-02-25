import hre from "hardhat";
import { forkConfig } from "../hardhat.config";

async function reset() {
  await hre.network.provider.request({
    method: "hardhat_reset",
    params: [
      {
        forking: forkConfig,
      },
    ],
  });
}

export default reset;
