// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.7.6;
pragma abicoder v2;

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Swaps {

    ISwapRouter public constant swapRouter =
       ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;


    IERC20 public constant weth9 = IERC20(WETH9);


    // Pool fee = 0.3%.
    uint24 public constant poolFee = 3000;

    constructor() {}

    // SingleSwaps

    function swapExactInputSingle(uint256 amountIn) external returns (uint256 amountOut) {

        weth9.transferFrom(msg.sender, address(this), amountIn);

        weth9.approve(address(swapRouter), amountIn);

        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: WETH9,
                tokenOut: DAI,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter.exactInputSingle(params);

    }

    /// @notice swaps a minimum possible amount of WETH for a fixed amount of DAI.
    function swapExactOutputSingle(uint256 amountOut, uint256 amountInMaximum) external returns (uint256 amountIn) {

        // Transfer the specified amount of WETH9 to this contract.
        weth9.transferFrom(msg.sender, address(this), amountInMaximum);

        weth9.approve(address(swapRouter), amountInMaximum);

        ISwapRouter.ExactOutputSingleParams memory params =
            ISwapRouter.ExactOutputSingleParams({
                tokenIn: WETH9,
                tokenOut: DAI,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOut,
                amountInMaximum: amountInMaximum,
                sqrtPriceLimitX96: 0
            });

        amountIn = swapRouter.exactOutputSingle(params);

        if (amountIn < amountInMaximum) {
            weth9.approve(address(swapRouter), 0);
            weth9.transfer(msg.sender, amountInMaximum - amountIn);
        }

    }

    // MultiHopSwaps

    function swapExactInputMultihop(uint256 amountIn) external returns (uint256 amountOut) {
        // Transfer `amountIn` of WETH9 to this contract.
        weth9.transferFrom(msg.sender, address(this), amountIn);

        // Approve the router to spend WETH9.
        weth9.approve(address(swapRouter), amountIn);

        ISwapRouter.ExactInputParams memory params =
            ISwapRouter.ExactInputParams({
                path: abi.encodePacked(WETH9, poolFee, USDC, poolFee, DAI),
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0
            });

        // Executes the swap.
        amountOut = swapRouter.exactInput(params);
    }

    function swapExactOutputMultihop(uint256 amountOut, uint256 amountInMaximum) external returns (uint256 amountIn) {
        // Transfer the specified `amountInMaximum` to this contract.
        weth9.transferFrom(msg.sender, address(this), amountInMaximum);
        // Approve the router to spend  `amountInMaximum`.
        weth9.approve(address(swapRouter), amountInMaximum);

        ISwapRouter.ExactOutputParams memory params =
            ISwapRouter.ExactOutputParams({
                path: abi.encodePacked(DAI, uint24(100), USDC, poolFee, WETH9),
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOut,
                amountInMaximum: amountInMaximum
            });

        // Executes the swap, returning the amountIn actually spent.
        amountIn = swapRouter.exactOutput(params);

        // If the swap did not require the full amountInMaximum to achieve the exact amountOut then we refund msg.sender and approve the router to spend 0.
        if (amountIn < amountInMaximum) {
            weth9.approve(address(swapRouter), 0);
            weth9.transferFrom(address(this), msg.sender, amountInMaximum - amountIn);
        }
    }

}