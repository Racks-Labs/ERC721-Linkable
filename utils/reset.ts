import hre from "hardhat"

async function reset() {
  await hre.network.provider.request({
    method: "hardhat_reset",
    params: [{forking: {
    jsonRpcUrl: process.env.ALCHEMY_POLYGON,
    blockNumber: Number(process.env.MRC_BLOCKNUMBER)
    },},],
  });
}

export default reset;
