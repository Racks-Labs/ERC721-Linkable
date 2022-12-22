import dotenv from 'dotenv'
import { expect } from "chai";
import hre from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

import reset from "../utils/reset"

const ethers = hre.ethers;
dotenv.config();

describe('Basic funcionality test', function () {
  let E7L:any, MRC:any
  let jommys:SignerWithAddress, yonathan:SignerWithAddress

  this.beforeAll(async function () {
    reset()
  })

  beforeEach(async function () {
     yonathan = await ethers.getImpersonatedSigner("0x4C9a3E12e523493383dd59162ECc8a26812192bE")
     jommys = await ethers.getImpersonatedSigner("0x0AeaC6D1424EA6d0F87123A50CA5eEc9f16108c5")
     MRC = await ethers.getContractAt("IMRC", "0xeF453154766505FEB9dBF0a58E6990fd6eB66969")

     const E7L_Factory = await ethers.getContractFactory("E7L");
     E7L = await E7L_Factory.connect(jommys).deploy("E7L", "E7L", MRC.address);

     (await E7L.connect(yonathan).mint(0));
  })

  it('Check ownership of token 0', async function () {
    expect(await E7L.ownerOf(0)).to.be.equal(yonathan.address);
    expect(await E7L.balanceOf(yonathan.address)).to.be.equal(1);
  })

  describe('linkToken()', function () {
    it('Should not be linked', async function () {
      const res = await E7L.tokenInfo(0);
      expect(res.linked).to.be.equal(false);
      expect(res.parentTokenId).to.be.equal(0);
    })

    it('Should link token', async function () {
      await E7L.connect(yonathan).linkToken(0, 2)
      const res = await E7L.tokenInfo(0)
      expect(res.linked).to.be.equal(true)
      expect(res.parentTokenId).to.be.equal(2)
    })
  })
  describe('syncToken()', function () {
    it('Should not transfer token', async function () {
      await E7L.connect(yonathan).linkToken(0, 2)
      await MRC.connect(yonathan).transferFrom(yonathan.address, jommys.address, 2)
      expect(await MRC.ownerOf(2)).to.be.equal(jommys.address)
      expect(await E7L.ownerOf(0)).to.be.equal(yonathan.address)
      reset();
    })

    it('Should transfer token', async function () {
      await E7L.connect(yonathan).linkToken(0, 2)
      await MRC.connect(yonathan).transferFrom(yonathan.address, jommys.address, 2)
      expect(await MRC.ownerOf(2)).to.be.equal(jommys.address)
      expect(await E7L.ownerOf(0)).to.be.equal(yonathan.address)
      await E7L.syncToken(0);
      expect(await E7L.ownerOf(0)).to.be.equal(jommys.address)
    })

  })
})
