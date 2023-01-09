import hre from "hardhat";
import { env } from "../env";

async function reset() {
  await hre.network.provider.request({
    method: "hardhat_reset",
    params: [
      {
        forking: {
          jsonRpcUrl: env.ALCHEMY_POLYGON,
          blockNumber: env.MRC_BLOCKNUMBER,
        },
      },
    ],
  });
}

export default reset;
