/**
 *Submitted for verification at Etherscan.io on 2024-04-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenPresale {
    IERC20 public token;
    address public owner;
    uint256 public price;
    bool public saleActive;

    event Purchase(address indexed buyer, uint256 amount);

    constructor(address _token, uint256 _price) {
        require(_price > 0, "Price should be greater than 0");

        token = IERC20(_token);
        owner = msg.sender;
        price = _price;
        saleActive = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function startSale() external onlyOwner {
        require(!saleActive, "Sale already active");
        saleActive = true;
    }

    function stopSale() external onlyOwner {
        require(saleActive, "Sale not active");
        saleActive = false;
    }

    function buyTokens(uint256 tokenAmount) external payable {
        require(saleActive, "Sale not active");
        require(tokenAmount > 0, "Cannot purchase 0 tokens");
        require(token.balanceOf(address(this)) >= tokenAmount, "Insufficient tokens");

        uint256 requiredETH = tokenAmount * price;
        require(msg.value >= requiredETH, "Insufficient ETH sent");

        uint256 tokenToTransfer = tokenAmount * 10 ** 18;

        token.transfer(msg.sender, tokenToTransfer);
        emit Purchase(msg.sender, tokenAmount);

        // Refund excess ETH, if any
        if (msg.value > requiredETH) {
            payable(msg.sender).transfer(msg.value - requiredETH);
        }
    }

    function withdrawETH() external onlyOwner {
        require(!saleActive, "Sale must be stopped before withdrawing ETH");
        payable(owner).transfer(address(this).balance);
    }

    function withdrawTokens() external onlyOwner {
        require(!saleActive, "Sale must be stopped before withdrawing tokens");
        token.transfer(owner, token.balanceOf(address(this)));
    }
}