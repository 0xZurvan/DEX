const { expect } = require("chai");
const { ethers } = require("hardhat");

const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const WETH9 = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"

describe("Swaps", function () {

  let Swaps;
  let accounts;
  let weth9;
  let dai;
  let usdc

  beforeEach(async function() {

    accounts = await ethers.getSigners();

    const swaps = await ethers.getContractFactory("Swaps");
    Swaps = await swaps.deploy();
    await Swaps.deployed();

    weth9 = await ethers.getContractAt("IWETH", WETH9);
    dai = await ethers.getContractAt("IERC20", DAI);

  });

  describe("SingleSwaps", function() {

    it("swapExactInputSingle", async function() {
      const amountIn = 10n ** 18n;
  
      await weth9.connect(accounts[0]).deposit({ value: amountIn });
      await weth9.connect(accounts[0]).approve(Swaps.address, amountIn);
  
      await Swaps.swapExactInputSingle(amountIn);
  
      console.log("DAI balance is:", await dai.balanceOf(accounts[0].address));
  
    });
  
    it("swapExactOutputSingle", async function() {
      const wethAmountInMax = 10n ** 18n;
      const daiAmountOut = 100n * 10n ** 18n;
  
      await weth9.connect(accounts[0]).deposit({ value: wethAmountInMax });
      await weth9.connect(accounts[0]).approve(Swaps.address, wethAmountInMax);
  
      await Swaps.swapExactOutputSingle(daiAmountOut, wethAmountInMax);
  
      console.log("DAI balance is:", await dai.balanceOf(accounts[0].address));
  
    });

  });

  describe("MultiHopSwaps", function() {
    
    it("swapExactInputMultihop", async function() {
      const amountIn = 10n ** 18n;
  
      await weth9.connect(accounts[0]).deposit({ value: amountIn });
      await weth9.connect(accounts[0]).approve(Swaps.address, amountIn);
  
      await Swaps.swapExactInputMultihop(amountIn);
  
      console.log("DAI balance is:", await dai.balanceOf(accounts[0].address));
  
    });

    it("swapExactOutputMultihop", async function() {
      
      const wethAmountInMax = 10n ** 18n;
      const daiAmountOut = 100n * 10n ** 18n;
  
      await weth9.connect(accounts[0]).deposit({ value: wethAmountInMax });
      await weth9.connect(accounts[0]).approve(Swaps.address, wethAmountInMax);

      await Swaps.swapExactOutputMultihop(daiAmountOut, wethAmountInMax);
  
      console.log("DAI balance is:", await dai.balanceOf(accounts[0].address));
  
    });

  });

});
