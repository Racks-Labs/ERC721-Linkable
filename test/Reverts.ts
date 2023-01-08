import { expect } from "chai";
import hre from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { E7LBasic, IMRC } from "../typechain-types";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

import reset from "../utils/reset";

const ethers = hre.ethers;

describe("Reverts test", function () {
  let E7L: E7LBasic, MRC: IMRC;
  let jommys: SignerWithAddress, yonathan: SignerWithAddress;

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

    await E7L.connect(yonathan).mint(0);
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
