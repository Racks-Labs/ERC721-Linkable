import hre from "hardhat"

async function reset() {
  await hre.network.provider.request({
    method: "hardhat_reset",
    params: [{forking: {
    jsonRpcUrl: process.env.ALCHEMY_POLYGON,
    blockNumber: 35079287
    },},],
  });
}

export default reset;
