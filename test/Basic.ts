import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { E7LBasic, MRCRYPTO } from "../typechain-types";
import { deployBasic } from "../utils/deployBasic";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { ethers } from "hardhat";

describe("E7L: Basic functionality test", function () {
  let E7L: E7LBasic, MRC: MRCRYPTO;
  let jommys: SignerWithAddress, yonathan: SignerWithAddress;

  async function deploy() {
    const deployed = await deployBasic();
    E7L = deployed.E7L;
    MRC = deployed.MRC;
    yonathan = deployed.yonathan;
    jommys = deployed.jommys;
  }

  beforeEach(async function () {
    await loadFixture(deploy);
  });

  it("Check ownership of token 0", async function () {
    expect(await E7L.ownerOf(0)).to.be.equal(yonathan.address);
    expect(await E7L.balanceOf(yonathan.address)).to.be.equal(1);
  });

  describe("linkToken()", function () {
    it("Should not be linked", async function () {
      const res = await E7L.tokenInfo(0);
      expect(res.parentContract).to.be.equal(ethers.constants.AddressZero);
      expect(res.parentTokenId).to.be.equal(0);
    });

    it("Should link token", async function () {
      await E7L.connect(yonathan).linkToken(0, 2, MRC.address);

      const res = await E7L.tokenInfo(0);

      expect(res.parentContract).to.be.not.equal(ethers.constants.AddressZero);
      expect(res.parentTokenId).to.be.equal(2);
    });
  });
  describe("syncToken()", function () {
    it("Should not transfer token", async function () {
      await E7L.connect(yonathan).linkToken(0, 2, MRC.address);
      await MRC.connect(yonathan).transferFrom(
        yonathan.address,
        jommys.address,
        2,
      );
      expect(await MRC.ownerOf(2)).to.be.equal(jommys.address);
      expect(await E7L.ownerOf(0)).to.be.equal(yonathan.address);
    });

    it("Should transfer token", async function () {
      await E7L.connect(yonathan).linkToken(0, 2, MRC.address);
      await MRC.connect(yonathan).transferFrom(
        yonathan.address,
        jommys.address,
        2,
      );
      expect(await MRC.ownerOf(2)).to.be.equal(jommys.address);
      expect(await E7L.ownerOf(0)).to.be.equal(yonathan.address);
      await E7L.syncToken(0);
      expect(await E7L.ownerOf(0)).to.be.equal(jommys.address);
    });
  });
});
