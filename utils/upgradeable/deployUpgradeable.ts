import { ethers } from "hardhat";
import { env } from "../../env";
import { E7LUpgradeableBasic, MRCRYPTO } from "../../typechain-types";
import reset from "../reset";

const MR_CRYPTO_ADDRESS = "0xeF453154766505FEB9dBF0a58E6990fd6eB66969";
const YONATHAN_ADDRESS = "0x4C9a3E12e523493383dd59162ECc8a26812192bE";
const JOMMYS_ADDRESS = "0x0AeaC6D1424EA6d0F87123A50CA5eEc9f16108c5";

export async function deployBasic() {
  const yonathan = await ethers.getImpersonatedSigner(YONATHAN_ADDRESS);
  const jommys = await ethers.getImpersonatedSigner(JOMMYS_ADDRESS);

  let MRC: MRCRYPTO, E7L_Proxy: E7LUpgradeableBasic;

  if (env.TEST_LOCAL_BLOCKCHAIN) {
    // Deploy a Mock of My.Crypto Contract
    const MRC_Factory = await ethers.getContractFactory("MRCRYPTO");
    MRC = await MRC_Factory.deploy(
      "MrCryptoMock",
      "MRC",
      "https://apinft.racksmafia.com/api/",
      "https://apinft.racksmafia.com/api/hidden.json",
    );

    await MRC.waitForDeployment();

    // Deploy a Mock of E7L Contract
    const E7L_Factory = await ethers.getContractFactory("E7LUpgradeableBasic");
    const E7L = await E7L_Factory.deploy();
    await E7L.waitForDeployment();

    const E7LProxy_Factory = await ethers.getContractFactory("E7LProxy");
    const E7LProxy_Raw = await E7LProxy_Factory.deploy(E7L.getAddress());
    await E7LProxy_Raw.waitForDeployment();

    E7L_Proxy = E7L.attach(
      await E7LProxy_Raw.getAddress(),
    ) as E7LUpgradeableBasic;

    const tx = await E7L_Proxy.initialize("E7L", "E7L", MRC.getAddress());
    await tx.wait();

    // Send ETH to Yonathan and Jommys
    const [owner] = await ethers.getSigners();

    await owner.sendTransaction({
      to: YONATHAN_ADDRESS,
      value: ethers.parseEther("100.0"),
    });

    await owner.sendTransaction({
      to: JOMMYS_ADDRESS,
      value: ethers.parseEther("100.0"),
    });

    await MRC.mint(1);
    // Mint the Mr.Crypto #2 for Yonathan
    await MRC.connect(yonathan).mint(1);
    // Mint the Mr.Crypto #3 for Jommys
    await MRC.connect(jommys).mint(1);
  } else {
    // Use de actual Mr.Crypto Contract deployed on polygon with hardhat fork
    await reset();

    // Is necessary to do this after reset the fork to use Jommys' and Yonathan's accounts
    await ethers.getImpersonatedSigner(YONATHAN_ADDRESS);
    await ethers.getImpersonatedSigner(JOMMYS_ADDRESS);

    MRC = await ethers.getContractAt("MRCRYPTO", MR_CRYPTO_ADDRESS);

    const E7L_Factory = await ethers.getContractFactory("E7LUpgradeableBasic");
    const E7L = await E7L_Factory.connect(jommys).deploy();
    await E7L.waitForDeployment();

    const E7LProxy_Factory = await ethers.getContractFactory("E7LProxy");
    const E7LProxy_Raw = await E7LProxy_Factory.deploy(E7L.getAddress());
    await E7LProxy_Raw.waitForDeployment();

    E7L_Proxy = E7L.attach(
      await E7LProxy_Raw.getAddress(),
    ) as E7LUpgradeableBasic;

    const tx = await E7L_Proxy.initialize("E7L", "E7L", MRC.getAddress());
    await tx.wait();
  }

  // Mint the E7L with id 0 for Yonathan
  await E7L_Proxy.connect(yonathan).mint(0);

  return { MRC, E7L_Proxy, yonathan, jommys };
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
deployBasic().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
