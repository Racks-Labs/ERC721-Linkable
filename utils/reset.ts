import hre from "hardhat";

async function reset() {
  await hre.network.provider.request({
    method: "hardhat_reset",
    params: [
      {
        forking: {
          jsonRpcUrl:
            "https://polygon-mainnet.g.alchemy.com/v2/_HUbutLqySZBluKEPyp_QRBI2tXSc3gs",
          blockNumber: 35079287,
        },
      },
    ],
  });
}

export default reset;
