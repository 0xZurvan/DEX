const { expect } = require("chai");
const { ethers } = require("hardhat");

const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const WETH9 = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";

describe("SingleSwap", function () {

  let SingleSwap;
  let accounts;
  let weth9;
  let dai;

  beforeEach(async function() {

    accounts = await ethers.getSigners();

    const singleSwap = await ethers.getContractFactory("SingleSwap");
    SingleSwap = await singleSwap.deploy();
    await SingleSwap.deployed();

    weth9 = await ethers.getContractAt("IWETH", WETH9);
    dai = await ethers.getContractAt("IERC20", DAI);

  });

  it("swapExactInputSingle", async function() {
    const amountIn = 10n ** 18n;

    await weth9.connect(accounts[0]).deposit({ value: amountIn });
    await weth9.connect(accounts[0]).approve(SingleSwap.address, amountIn);

    await SingleSwap.swapExactInputSingle(amountIn);

    console.log("DAI balance is:", await dai.balanceOf(accounts[0].address));

  });

  it("swapExactOutputSingle", async function() {
    const wethAmountInMax = 10n ** 18n;
    const daiAmountOut = 100n * 10n ** 18n;

    await weth9.connect(accounts[0]).deposit({ value: wethAmountInMax });
    await weth9.connect(accounts[0]).approve(SingleSwap.address, wethAmountInMax);

    await SingleSwap.swapExactOutputSingle(daiAmountOut, wethAmountInMax);

    console.log("DAI balance is:", await dai.balanceOf(accounts[0].address));

  });

});
