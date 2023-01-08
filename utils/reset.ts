import hre from "hardhat"

async function reset() {
  await hre.network.provider.request({
    method: "hardhat_reset",
    params: [{forking: {
    jsonRpcUrl: "https://polygon-rpc.com/",
    blockNumber: 35079287
    },},],
  });
}

export default reset;
