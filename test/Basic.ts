import { expect } from "chai";
import { E7LBasic, MRCRYPTO } from "../typechain-types";
import { deployBasic } from "../utils/deployBasic";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { Signer } from "ethers";
import { ethers } from "hardhat";

describe("E7L: Basic functionality test", function () {
  let E7L: E7LBasic, MRC: MRCRYPTO;
  let jommys: Signer, yonathan: Signer;

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
    expect(await E7L.ownerOf(0)).to.be.equal(await yonathan.getAddress());
    expect(await E7L.balanceOf(await yonathan.getAddress())).to.be.equal(1);
  });

  describe("linkToken()", function () {
    it("Should not be linked", async function () {
      const res = await E7L.tokenInfo(0);
      expect(res.parentContract).to.be.equal(ethers.ZeroAddress);
      expect(res.parentTokenId).to.be.equal(0);
    });

    it("Should link token", async function () {
      await E7L.connect(yonathan).linkToken(0, 2, MRC.getAddress());

      const res = await E7L.tokenInfo(0);

      expect(res.parentContract).to.be.not.equal(ethers.ZeroAddress);
      expect(res.parentTokenId).to.be.equal(2);
    });
  });
  describe("unlinkToken()", function () {
    it("Should unlink token", async function () {
      await E7L.connect(yonathan).linkToken(0, 2, MRC.getAddress());

      let res = await E7L.tokenInfo(0);

      expect(res.parentContract).to.be.equal(await MRC.getAddress());
      expect(res.parentTokenId).to.be.equal(2);
      await E7L.connect(yonathan).unlinkToken(0);

      res = await E7L.tokenInfo(0);

      expect(res.parentContract).to.be.equal(ethers.ZeroAddress);
      expect(res.parentTokenId).to.be.equal(0);
    });
  });
  describe("syncToken()", function () {
    it("Should not transfer token", async function () {
      await E7L.connect(yonathan).linkToken(0, 2, MRC.getAddress());
      await MRC.connect(yonathan).transferFrom(
        yonathan.getAddress(),
        jommys.getAddress(),
        2,
      );
      expect(await MRC.ownerOf(2)).to.be.equal(await jommys.getAddress());
      expect(await E7L.ownerOf(0)).to.be.equal(await yonathan.getAddress());
    });

    it("Should transfer token", async function () {
      await E7L.connect(yonathan).linkToken(0, 2, MRC.getAddress());
      await MRC.connect(yonathan).transferFrom(
        yonathan.getAddress(),
        jommys.getAddress(),
        2,
      );
      expect(await MRC.ownerOf(2)).to.be.equal(await jommys.getAddress());
      expect(await E7L.ownerOf(0)).to.be.equal(await yonathan.getAddress());
      await E7L.syncToken(0);
      expect(await E7L.ownerOf(0)).to.be.equal(await jommys.getAddress());
    });
  });
});
