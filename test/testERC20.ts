import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";    
import { expect } from "chai";    
import { ethers } from "hardhat";    
import { ERC20 } from "../typechain-types/ERC20";
     
describe("MyERC20Contract", function () {    
 let myERC20Contract: ERC20;    
 let sender: SignerWithAddress, receiver: SignerWithAddress;    
     
 beforeEach(async function () {    
   const ERC20Contract = await ethers.getContractFactory("ERC20");    
   myERC20Contract = await ERC20Contract.deploy("Hello", "SYM");    
   await myERC20Contract.deployed();    
     
   sender = (await ethers.getSigners())[1];    
   receiver = (await ethers.getSigners())[2];    
 });    
     
 describe("when I have 10 tokens", function () {    
   beforeEach(async function () {    
     await myERC20Contract.transfer(sender.address, 10);    
   });    
     
   describe("when I transfer 10 tokens", function () {    
     it("should transfer tokens correctly", async function () {    
       await myERC20Contract.connect(sender).transfer(receiver.address, 10);    
       expect(await myERC20Contract.balanceOf(receiver.address)).to.equal(10);    
     });    
   });    
     
   describe("when I transfer 15 tokens", function () {    
     it("should revert the transfer", async function () {    
       expect(    
         myERC20Contract.connect(sender).transfer(receiver.address, 10)    
       ).to.be.revertedWith("ERC20: transfer amount exceeds balance");    
     });    
   });    
 });    
});