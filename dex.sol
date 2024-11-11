// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract DEX {
    address public owner;
    uint256 public feePercentage = 1;  // 1% fee for each transaction

    // Mapping to store token balances of users
    mapping(address => mapping(address => uint256)) public tokenBalances;

    event Swap(address indexed from, address indexed to, uint256 amountIn, uint256 amountOut);
    event Deposit(address indexed token, address indexed user, uint256 amount);
    event Withdraw(address indexed token, address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can execute this");
        _;
    }

    // Deposit ERC20 tokens into the DEX
    function deposit(address token, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        tokenBalances[token][msg.sender] += amount;
        emit Deposit(token, msg.sender, amount);
    }

    // Withdraw ERC20 tokens from the DEX
    function withdraw(address token, uint256 amount) external {
        require(tokenBalances[token][msg.sender] >= amount, "Insufficient balance");
        tokenBalances[token][msg.sender] -= amount;
        IERC20(token).transfer(msg.sender, amount);
        emit Withdraw(token, msg.sender, amount);
    }

    // Swap tokens
    function swap(address fromToken, address toToken, uint256 amountIn) external {
        require(amountIn > 0, "Amount must be greater than 0");
        uint256 amountOut = getAmountOut(fromToken, toToken, amountIn);
        require(amountOut > 0, "Insufficient liquidity or invalid swap");

        // Calculate the fee
        uint256 fee = (amountIn * feePercentage) / 100;
        uint256 amountAfterFee = amountIn - fee;

        // Transfer the input token from the user
        IERC20(fromToken).transferFrom(msg.sender, address(this), amountIn);
        // Transfer the output token to the user
        tokenBalances[fromToken][msg.sender] -= amountIn;
        tokenBalances[toToken][msg.sender] += amountOut;

        // Emit event
        emit Swap(msg.sender, toToken, amountIn, amountOut);
    }

    // Calculate the output amount based on the price (this is a simplified version)
    function getAmountOut(address fromToken, address toToken, uint256 amountIn) public view returns (uint256) {
        // Here, we just assume a 1:1 swap rate for simplicity. In a real DEX, there would be more logic here.
        return amountIn;  // For simplicity, we're not factoring liquidity pools or slippage
    }
}
