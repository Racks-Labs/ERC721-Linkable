import { expect } from "chai";
import { E7LUpgradeableBasic, MRCRYPTO } from "../typechain-types";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { Signer } from "ethers";

import { deployBasic } from "../utils/upgradeable/deployUpgradeable";

describe("E7LUpgradeable: Reverts test", function () {
  let E7L: E7LUpgradeableBasic, MRC: MRCRYPTO;
  let jommys: Signer, yonathan: Signer;

  async function deploy() {
    const deployed = await deployBasic();

    E7L = deployed.E7L_Proxy;
    MRC = deployed.MRC;
    yonathan = deployed.yonathan;
    jommys = deployed.jommys;
  }

  beforeEach(async function () {
    await loadFixture(deploy);
  });

  it("Check ownership of token 0", async function () {
    expect(await E7L.ownerOf(0)).to.be.equal(await yonathan.getAddress());
    expect(await E7L.balanceOf(yonathan.getAddress())).to.be.equal(1);
  });

  describe("_beforeTokenTransfer()", function () {
    it("Should revert with invalid address", async function () {
      await E7L.connect(yonathan).linkToken(0, 2, MRC.getAddress());
      await expect(
        E7L.connect(yonathan).transferFrom(
          yonathan.getAddress(),
          jommys.getAddress(),
          0,
        ),
      ).to.be.revertedWith(
        "ERC721LinkableUpgradeable: the 'to' address is not the legitimate owner",
      );
    });
  });
  describe("linkToken()", function () {
    it("Should revert with invalid token ID", async function () {
      await expect(
        E7L.connect(yonathan).linkToken(5, 1, MRC.getAddress()),
      ).to.be.revertedWith("ERC721: invalid token ID");
      await expect(
        E7L.connect(yonathan).linkToken(0, 100000, MRC.getAddress()),
      ).to.be.revertedWith("ERC721: owner query for nonexistent token");
    });

    it("Should revert with token already linked", async function () {
      await E7L.connect(yonathan).linkToken(0, 2, MRC.getAddress());
      await expect(
        E7L.connect(yonathan).linkToken(0, 2, MRC.getAddress()),
      ).to.be.revertedWith(
        "ERC721LinkableUpgradeable: token is already linked",
      );
    });

    it("Should revert with caller is not owner nor aproved", async function () {
      await expect(
        E7L.connect(jommys).linkToken(0, 2, MRC.getAddress()),
      ).to.be.revertedWith("ERC721: caller is not token owner nor approved");
    });
  });
  describe("syncToken()", function () {
    it("Should revert with token already synced", async function () {
      await E7L.connect(yonathan).linkToken(0, 2, MRC.getAddress());
      await expect(E7L.syncToken(0)).to.be.revertedWith(
        "ERC721LinkableUpgradeable: token already synced",
      );
    });
  });
  describe("tokenInfo()", function () {
    it("Should revert with invalid token ID", async function () {
      await expect(E7L.tokenInfo(3)).to.be.revertedWith(
        "ERC721: invalid token ID",
      );
    });
  });
});
