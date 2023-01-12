import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { E7LBasic } from "../typechain-types";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

import { deployContracts } from "../utils/deploy";

describe("Reverts test", function () {
  let E7L: E7LBasic;
  let jommys: SignerWithAddress, yonathan: SignerWithAddress;

  async function deploy() {
    const deployed = await deployContracts();

    E7L = deployed.E7L;
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

  describe("_beforeTokenTransfer()", function () {
    it("Should revert with is not linked", async function () {
      await expect(
        E7L.connect(yonathan).transferFrom(yonathan.address, jommys.address, 0),
      ).to.be.revertedWith(
        "ERC721Linkable: cannot transfer token because is not linked",
      );
    });

    it("Should revert with invalid address", async function () {
      await E7L.connect(yonathan).linkToken(0, 2);
      await expect(
        E7L.connect(yonathan).transferFrom(yonathan.address, jommys.address, 0),
      ).to.be.revertedWith("ERC721Linkable: invalid address. Use syncToken()");
    });
  });
  describe("linkToken()", function () {
    it("Should revert with invalid token ID", async function () {
      await expect(E7L.connect(yonathan).linkToken(5, 1)).to.be.revertedWith(
        "ERC721: invalid token ID",
      );
      await expect(
        E7L.connect(yonathan).linkToken(0, 100000),
      ).to.be.revertedWith("ERC721: owner query for nonexistent token");
    });

    it("Should revert with token already linked", async function () {
      await E7L.connect(yonathan).linkToken(0, 2);
      await expect(E7L.connect(yonathan).linkToken(0, 2)).to.be.revertedWith(
        "ERC721Linkable: token is already linked",
      );
    });

    it("Should revert with caller is not owner nor aproved", async function () {
      await expect(E7L.connect(jommys).linkToken(0, 2)).to.be.revertedWith(
        "ERC721: caller is not token owner nor approved",
      );
    });
  });
  describe("syncToken()", function () {
    it("Should revert with token already synced", async function () {
      await E7L.connect(yonathan).linkToken(0, 2);
      await expect(E7L.syncToken(0)).to.be.revertedWith(
        "ERC721Linkable: token already synced",
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
