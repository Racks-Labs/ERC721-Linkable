import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { E7LBasic, E7LManager, MRCRYPTO } from "../typechain-types";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { deployE7LManager } from "../utils/deployE7LManager";

describe("E7LManager tests", function () {
  let E7L: E7LBasic, MRC: MRCRYPTO, E7LManager: E7LManager;
  let tokens: Array<E7LManager.LinkedTokenStruct>;
  let jommys: SignerWithAddress, yonathan: SignerWithAddress;

  const MAX_BATCH_NUMBER = 150;

  async function deploy() {
    const deployE7LM = await deployE7LManager();
    E7L = deployE7LM.E7L;
    MRC = deployE7LM.MRC;
    E7LManager = deployE7LM.E7LManager;
    yonathan = deployE7LM.yonathan;
    jommys = deployE7LM.jommys;
  }

  beforeEach(async function () {
    await loadFixture(deploy);

    tokens = [
      { id: 0, contractAddress: E7L.address },
      { id: 1, contractAddress: E7L.address },
      { id: 2, contractAddress: E7L.address },
    ];
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
      await E7LManager.connect(yonathan).linkTokens(MRC.address, 2, tokens);

      const res = await E7L.tokenInfo(0);
      expect(res.linked).to.be.true;
      expect(res.parentTokenId).to.be.equal(2);

      const res1 = await E7L.tokenInfo(1);
      expect(res1.linked).to.be.true;
      expect(res1.parentTokenId).to.be.equal(2);

      const res2 = await E7L.tokenInfo(2);
      expect(res2.linked).to.be.true;
      expect(res2.parentTokenId).to.be.equal(2);
    });

    it("Should link MAX_BATCH_NUMBER tokens", async function () {
      for (let i = 3; i < MAX_BATCH_NUMBER; i++) {
        await E7L.connect(yonathan).mint(i);
        tokens.push({ id: i, contractAddress: E7L.address });
      }
      await E7LManager.connect(yonathan).linkTokens(MRC.address, 2, tokens);
      expect(
        (await E7LManager.getLinkedTokensFromParent(MRC.address, 2)).length,
      ).to.be.equal(MAX_BATCH_NUMBER);
    });

    it("Should link tokens in several batchesShould link tokens in several batches", async function () {
      for (let i = 3; i < MAX_BATCH_NUMBER; i++) {
        await E7L.connect(yonathan).mint(i);
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
      expect(res.linked).to.be.true;
      expect(res.parentTokenId).to.be.equal(2);
    });
  });
  describe("syncTokens()", function () {
    it("Should not transfer tokens", async function () {
      await E7LManager.connect(yonathan).linkTokens(MRC.address, 2, tokens);
      await MRC.connect(yonathan).transferFrom(
        yonathan.address,
        jommys.address,
        2,
      );
      expect(await MRC.ownerOf(2)).to.be.equal(jommys.address);
      expect(await E7L.ownerOf(0)).to.be.equal(yonathan.address);
    });

    it("Should transfer 3 tokens", async function () {
      await E7LManager.connect(yonathan).linkTokens(MRC.address, 2, tokens);
      await MRC.connect(yonathan).transferFrom(
        yonathan.address,
        jommys.address,
        2,
      );
      expect(await MRC.ownerOf(2)).to.be.equal(jommys.address);
      await E7LManager.syncTokens(MRC.address, 2);

      expect(await E7L.ownerOf(0)).to.be.equal(jommys.address);
      expect(await E7L.ownerOf(1)).to.be.equal(jommys.address);
      expect(await E7L.ownerOf(2)).to.be.equal(jommys.address);
    });

    it("Should transfer MAX_BATCH_NUMBER tokens", async function () {
      for (let i = 3; i < MAX_BATCH_NUMBER; i++) {
        await E7L.connect(yonathan).mint(i);
        tokens.push({ id: i, contractAddress: E7L.address });
      }
      await E7LManager.connect(yonathan).linkTokens(MRC.address, 2, tokens);
      await MRC.connect(yonathan).transferFrom(
        yonathan.address,
        jommys.address,
        2,
      );

      expect(await MRC.ownerOf(2)).to.be.equal(jommys.address);
      await E7LManager.syncTokens(MRC.address, 2);
      for (let i = 0; i < MAX_BATCH_NUMBER; i++) {
        expect(await E7L.ownerOf(i)).to.be.equal(jommys.address);
      }
    });

    it("Should transfer above MAX_BATCH_NUMBER tokens", async function () {
      for (let i = 3; i < MAX_BATCH_NUMBER; i++) {
        await E7L.connect(yonathan).mint(i);
        tokens.push({ id: i, contractAddress: E7L.address });
      }
      await E7LManager.connect(yonathan).linkTokens(MRC.address, 2, tokens);

      const tokens2 = [];
      for (let i = MAX_BATCH_NUMBER; i < MAX_BATCH_NUMBER * 2; i++) {
        await E7L.connect(yonathan).mint(i);
        tokens2.push({ id: i, contractAddress: E7L.address });
      }
      await E7LManager.connect(yonathan).linkTokens(MRC.address, 2, tokens2);

      const tokens3 = [];
      for (let i = MAX_BATCH_NUMBER * 2; i < MAX_BATCH_NUMBER * 3; i++) {
        await E7L.connect(yonathan).mint(i);
        tokens3.push({ id: i, contractAddress: E7L.address });
      }
      await E7LManager.connect(yonathan).linkTokens(MRC.address, 2, tokens3);

      await MRC.connect(yonathan).transferFrom(
        yonathan.address,
        jommys.address,
        2,
      );

      expect(await MRC.ownerOf(2)).to.be.equal(jommys.address);
      await E7LManager.syncTokens(MRC.address, 2);
      for (let i = 0; i < MAX_BATCH_NUMBER * 3; i++) {
        expect(await E7L.ownerOf(i)).to.be.equal(jommys.address);
      }
    });
  });
});
