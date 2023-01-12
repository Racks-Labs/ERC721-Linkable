import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import { env } from "./env";

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  gasReporter: {
    enabled: false,
  },
  mocha: {
    timeout: 60000,
  },
};

export const forkConfig = {
  jsonRpcUrl: env.ALCHEMY_POLYGON,
  blockNumber: env.MRC_BLOCKNUMBER,
};

export default config;
