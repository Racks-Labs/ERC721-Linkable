import { expect } from "chai";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { IMRC, E7LBasic, E7LManager } from "../typechain-types";
import reset from "../utils/reset";

describe("E7LManager tests", function () {
  let E7L: E7LBasic, MRC: IMRC, E7LManager: E7LManager;
  let jommys: SignerWithAddress, yonathan: SignerWithAddress;
  const MAX_BATCH_NUMBER = 260;
  this.beforeAll(async function () {
    await reset();
  });

  async function deploy() {
    yonathan = await ethers.getImpersonatedSigner(
      "0x4C9a3E12e523493383dd59162ECc8a26812192bE",
    );
    jommys = await ethers.getImpersonatedSigner(
      "0x0AeaC6D1424EA6d0F87123A50CA5eEc9f16108c5",
    );
    MRC = await ethers.getContractAt(
      "IMRC",
      "0xeF453154766505FEB9dBF0a58E6990fd6eB66969",
    );

    const E7L_Factory = await ethers.getContractFactory("E7LBasic");
    E7L = await E7L_Factory.connect(jommys).deploy("E7L", "E7L", MRC.address);

    const E7LManager_Factory = await ethers.getContractFactory("E7LManager");
    E7LManager = await E7LManager_Factory.connect(jommys).deploy();

    await E7L.connect(yonathan).mint(0);
    await E7L.connect(yonathan).mint(1);
    await E7L.connect(yonathan).mint(2);

    await E7L.connect(yonathan).approve(E7LManager.address, 0);
    await E7L.connect(yonathan).approve(E7LManager.address, 1);
    await E7L.connect(yonathan).approve(E7LManager.address, 2);
  }

  beforeEach(async function () {
    await deploy();
  });

  it("Check ownership of tokens 0, 1, 2", async function () {
    expect(await E7L.ownerOf(0)).to.be.equal(yonathan.address);
    expect(await E7L.ownerOf(1)).to.be.equal(yonathan.address);
    expect(await E7L.ownerOf(2)).to.be.equal(yonathan.address);
    expect(await E7L.balanceOf(yonathan.address)).to.be.equal(3);
  });

  describe("linkTokens()", function () {
    it("Should not have any linked token", async function () {
      expect(
        (await E7LManager.getLinkedTokensFromParent(MRC.address, 2)).length,
      ).to.be.equal(0);
    });

    it("Should link 3 tokens", async function () {
      await E7LManager.connect(yonathan).linkTokens(MRC.address, 2, [
        { id: 0, contractAddress: E7L.address },
        { id: 1, contractAddress: E7L.address },
        { id: 2, contractAddress: E7L.address },
      ]);

      const res = await E7L.tokenInfo(0);
      expect(res.linked).to.be.true;
      expect(res.parentTokenId).to.be.equal(2);

      const res1 = await E7L.tokenInfo(1);
      expect(res1.linked).to.be.equal(true);
      expect(res1.parentTokenId).to.be.equal(2);

      const res2 = await E7L.tokenInfo(2);
      expect(res2.linked).to.be.equal(true);
      expect(res2.parentTokenId).to.be.equal(2);
    });

    it("Should link MAX_BATCH_NUMBER tokens", async function () {
      const tokens = [
        { id: 0, contractAddress: E7L.address },
        { id: 1, contractAddress: E7L.address },
        { id: 2, contractAddress: E7L.address },
      ];
      for (let i = 3; i < MAX_BATCH_NUMBER; i++) {
        await E7L.connect(yonathan).mint(i);
        await E7L.connect(yonathan).approve(E7LManager.address, i);
        tokens.push({ id: i, contractAddress: E7L.address });
      }
      await E7LManager.connect(yonathan).linkTokens(MRC.address, 2, tokens);
      expect(
        (await E7LManager.getLinkedTokensFromParent(MRC.address, 2)).length,
      ).to.be.equal(MAX_BATCH_NUMBER);
    });

    it("Should link tokens in several batches", async function () {
      const tokens = [
        { id: 0, contractAddress: E7L.address },
        { id: 1, contractAddress: E7L.address },
        { id: 2, contractAddress: E7L.address },
      ];
      for (let i = 3; i < MAX_BATCH_NUMBER; i++) {
        await E7L.connect(yonathan).mint(i);
        await E7L.connect(yonathan).approve(E7LManager.address, i);
        tokens.push({ id: i, contractAddress: E7L.address });
      }
      await E7LManager.connect(yonathan).linkTokens(MRC.address, 2, tokens);

      const tokens2 = [];
      await E7L.connect(yonathan).setApprovalForAll(E7LManager.address, true);
      for (let i = MAX_BATCH_NUMBER; i < MAX_BATCH_NUMBER * 2; i++) {
        await E7L.connect(yonathan).mint(i);
        tokens2.push({ id: i, contractAddress: E7L.address });
      }
      await E7LManager.connect(yonathan).linkTokens(MRC.address, 2, tokens2);

      expect(
        (await E7LManager.getLinkedTokensFromParent(MRC.address, 2)).length,
      ).to.be.equal(MAX_BATCH_NUMBER * 2);

      const res = await E7L.tokenInfo(MAX_BATCH_NUMBER - 1);
      expect(res.linked).to.be.equal(true);
      expect(res.parentTokenId).to.be.equal(2);
    });
  });
  describe("syncTokens()", function () {
    it("Should not transfer tokens", async function () {
      await E7LManager.connect(yonathan).linkTokens(MRC.address, 2, [
        { id: 0, contractAddress: E7L.address },
        { id: 1, contractAddress: E7L.address },
        { id: 2, contractAddress: E7L.address },
      ]);
      await MRC.connect(yonathan).transferFrom(
        yonathan.address,
        jommys.address,
        2,
      );
      expect(await MRC.ownerOf(2)).to.be.equal(jommys.address);
      expect(await E7L.ownerOf(0)).to.be.equal(yonathan.address);
      await reset();
    });

    it("Should transfer 3 tokens", async function () {
      await E7LManager.connect(yonathan).linkTokens(MRC.address, 2, [
        { id: 0, contractAddress: E7L.address },
        { id: 1, contractAddress: E7L.address },
        { id: 2, contractAddress: E7L.address },
      ]);
      await MRC.connect(yonathan).transferFrom(
        yonathan.address,
        jommys.address,
        2,
      );
      expect(await MRC.ownerOf(2)).to.be.equal(jommys.address);
      expect(await E7L.ownerOf(0)).to.be.equal(yonathan.address);
      expect(await E7L.ownerOf(1)).to.be.equal(yonathan.address);
      expect(await E7L.ownerOf(2)).to.be.equal(yonathan.address);

      await E7LManager.syncTokens(MRC.address, 2);

      expect(await E7L.ownerOf(0)).to.be.equal(jommys.address);
      expect(await E7L.ownerOf(1)).to.be.equal(jommys.address);
      expect(await E7L.ownerOf(2)).to.be.equal(jommys.address);
      await reset();
    });

    it("Should transfer MAX_BATCH_NUMBER tokens", async function () {
      const tokens = [
        { id: 0, contractAddress: E7L.address },
        { id: 1, contractAddress: E7L.address },
        { id: 2, contractAddress: E7L.address },
      ];
      for (let i = 3; i < MAX_BATCH_NUMBER; i++) {
        await E7L.connect(yonathan).mint(i);
        await E7L.connect(yonathan).approve(E7LManager.address, i);
        tokens.push({ id: i, contractAddress: E7L.address });
      }
      await E7LManager.connect(yonathan).linkTokens(MRC.address, 2, tokens);
      await MRC.connect(yonathan).transferFrom(
        yonathan.address,
        jommys.address,
        2,
      );

      expect(await MRC.ownerOf(2)).to.be.equal(jommys.address);
      for (let i = 0; i < MAX_BATCH_NUMBER; i++) {
        expect(await E7L.ownerOf(i)).to.be.equal(yonathan.address);
      }
      await E7LManager.syncTokens(MRC.address, 2);
      for (let i = 0; i < MAX_BATCH_NUMBER; i++) {
        expect(await E7L.ownerOf(i)).to.be.equal(jommys.address);
      }
      await reset();
    });

    it("Should transfer above MAX_BATCH_NUMBER tokens", async function () {
      const tokens = [
        { id: 0, contractAddress: E7L.address },
        { id: 1, contractAddress: E7L.address },
        { id: 2, contractAddress: E7L.address },
      ];
      for (let i = 3; i < MAX_BATCH_NUMBER; i++) {
        await E7L.connect(yonathan).mint(i);
        await E7L.connect(yonathan).approve(E7LManager.address, i);
        tokens.push({ id: i, contractAddress: E7L.address });
      }
      await E7LManager.connect(yonathan).linkTokens(MRC.address, 2, tokens);

      const tokens2 = [];
      for (let i = MAX_BATCH_NUMBER; i < MAX_BATCH_NUMBER * 2; i++) {
        await E7L.connect(yonathan).mint(i);
        await E7L.connect(yonathan).approve(E7LManager.address, i);
        tokens2.push({ id: i, contractAddress: E7L.address });
      }
      await E7LManager.connect(yonathan).linkTokens(MRC.address, 2, tokens2);

      const tokens3 = [];
      for (let i = MAX_BATCH_NUMBER * 2; i < MAX_BATCH_NUMBER * 3; i++) {
        await E7L.connect(yonathan).mint(i);
        await E7L.connect(yonathan).approve(E7LManager.address, i);
        tokens3.push({ id: i, contractAddress: E7L.address });
      }
      await E7LManager.connect(yonathan).linkTokens(MRC.address, 2, tokens3);

      await MRC.connect(yonathan).transferFrom(
        yonathan.address,
        jommys.address,
        2,
      );

      expect(await MRC.ownerOf(2)).to.be.equal(jommys.address);
      for (let i = 0; i < MAX_BATCH_NUMBER * 3; i++) {
        expect(await E7L.ownerOf(i)).to.be.equal(yonathan.address);
      }
      await E7LManager.syncTokens(MRC.address, 2);
      for (let i = 0; i < MAX_BATCH_NUMBER * 3; i++) {
        expect(await E7L.ownerOf(i)).to.be.equal(jommys.address);
      }
      await reset();
    });
  });
});
