// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "hardhat/console.sol";

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
// import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./interfaces/ICryptoPageBank.sol";
import "./interfaces/ICryptoPageToken.sol";
import "./interfaces/ICryptoPageCommentDeployer.sol";

/// @title The contract calculates amount and mint / burn PAGE tokens
/// @author Crypto.Page Team
/// @notice
/// @dev
contract PageBank is OwnableUpgradeable, IPageBank {
    using SafeMathUpgradeable for uint256;

    /// Address of Crypto.Page treasury
    address public treasury;
    /// Address of CryptoPageNFT contract
    address public nft;
    /// Address of CryptoPageCommentDeployer contract
    address public commentDeployer;
    /// Treasury fee (1000 is 10%, 100 is 1% 10 is 0.1%)
    uint256 public treasuryFee;
    /// CryptoPageToken interface
    IPageToken public token;
    // UniswapV3Pool interface for USDT / PAGE pool
    IUniswapV3Pool private usdtpagePool;
    // UniswapV3Pool interface for WETH / USDT pool
    IUniswapV3Pool private wethusdtPool;

    // address private weth;
    // address private usdt;

    // Storage balance per address
    mapping(address => uint256) private _balances;

    /// Modifier for functions that can call only from CryptoPageNFT address
    /*
    modifier onlyNFT() {
        require(
            _msgSender() == nft,
            "PageBank. Only PageNFT can call this function"
        );
        _;
    }

    /// Modifier for functions that can call only from CryptoPageCommentDeployer address
    modifier onlyCommentDeployer() {
        require(
            _msgSender() == commentDeployer,
            "PageBank. Only PageCommentDeployer can call this function"
        );
        _;
    }
    */

    /// @notice Initial function
    /// @param _treasury Address of our treasury
    /// @param _nft Address of ERC721 contract
    /// @param _commentDeployer Address of PageCommentDeployer contract
    /// @param _treasuryFee Percent of treasury fee (1000 is 10%; 100 is 1%; 10 is 0.1%)
    function initialize(
        address _treasury,
        address _token,
        address _nft,
        address _commentDeployer,
        uint256 _treasuryFee
    ) public initializer {
        __Ownable_init();
        treasury = _treasury;
        token = IPageToken(_token);
        nft = _nft;
        treasuryFee = _treasuryFee;
        commentDeployer = _commentDeployer;
    }

    function calculateMint(
        address sender,
        address receiver,
        uint256 amount
    ) public override returns (uint256) {
        amount = _calculateAmount(amount);
        uint256 treasuryAmount = _calculateTreasuryAmount(amount);
        if (sender == receiver) {
            amount += _refund(sender);
            _setBalance(treasury, _addBalance(treasury, treasuryAmount));
            token.mint(sender, amount);
        } else {
            _setBalance(treasury, _addBalance(treasury, treasuryAmount));
            _setBalance(receiver, _addBalance(receiver, amount));
            amount = amount.sub(2);
            token.mint(sender, amount += _refund(sender));
        }
        return amount;
    }

    function calculateBurn(
        address receiver,
        uint256 gas,
        uint256 commentsReward
    ) public override returns (uint256) {
        uint256 amount = _calculateAmount(gas);
        console.log("amount is %s", amount);
        commentsReward = _calculateAmount(commentsReward);
        if (amount > commentsReward) {
            amount = amount.sub(commentsReward);
        }
        console.log("balance of %s", receiver);
        console.log("is %s", token.balanceOf(receiver));
        token.burn(receiver, amount);
        return amount;
    }

    function withdraw(uint256 amount) public payable override {
        require(_balances[_msgSender()] >= amount, "Not enough balance");
        _subBalance(_msgSender(), amount);
        token.mint(_msgSender(), amount);
    }

    function balanceOf() public view override returns (uint256) {
        return _balances[_msgSender()];
    }

    /// @notice Function for calling from PageNFT.safeMint
    /// @param to Address for minting
    /// @param gas Amount of gas spent on the execution PageNFT.safeMint function
    /*
    function mint(address to, uint256 gas)
        public
        payable
        override
        onlyNFT
        returns (uint256)
    {
        uint256 amount = _calculateAmount(gas);
        uint256 treasuryAmount = _calculateTreasuryAmount(amount);

        amount += _refund(to);
        token.mint(to, amount);
        _setBalance(treasury, _addBalance(treasury, treasuryAmount));
        console.log("balance of treausry", _balances[treasury]);
        return amount;
    }

    /// @notice Function for calling from PageNFT.safeMint for another address
    /// @param from Sender's address
    /// @param to Owner's address of PAGE.NFT token
    /// @param gas Amount of gas spent on the execution PageNFT.safeMint function
    function mintFor(
        address from,
        address to,
        uint256 gas
    ) public payable override onlyNFT returns (uint256) {
        require(_msgSender() == from, "Only for owner");
        uint256 amount = _calculateAmount(gas);
        uint256 treasuryAmount = _calculateTreasuryAmount(amount);
        amount = amount.div(2);
        token.mint(from, amount += _refund(from));
        _setBalance(treasury, _addBalance(treasury, treasuryAmount));
        _setBalance(to, _addBalance(to, amount));
        return amount;
    }

    /// @notice Function for calling from PageNFT.safeBurn
    /// @param to Owner's address of PAGE.NFT token
    /// @param commentsReward Amount of gas spent on the execution PageNFT.safeBurn function
    function burn(
        address to,
        uint256 gas,
        uint256 commentsReward
    ) public payable override onlyNFT {
        uint256 amount = _calculateAmount(gas);
        console.log("amount is %s", amount);
        commentsReward = _calculateAmount(commentsReward);
        if (amount > commentsReward) {
            amount = amount.sub(commentsReward);
        }
        console.log("balance of %s", to);
        console.log("is %s", token.balanceOf(to));
        token.burn(to, amount);
    }

    /// @notice Function for calling from PageNFT.safeTransferFrom
    /// @param from Owner's address of PAGE.NFT token
    /// @param to Recipient address
    /// @param gas Amount of gas spent on the execution PageNFT.safeTransferFrom function
    function transferFrom(
        address from,
        address to,
        uint256 gas
    ) public payable override onlyNFT {
        uint256 amount = _calculateAmount(gas);
        uint256 treasuryAmount = _calculateTreasuryAmount(amount);
        amount = amount.div(2);
        _setBalance(to, _addBalance(to, amount));
        _setBalance(treasury, _addBalance(treasury, treasuryAmount));
        token.mint(from, amount += _refund(to));
    }
    
    /// @notice Function for calling from PageNFT.createComment
    /// @param from Comment author's address
    /// @param to Recipient address
    /// @param gas Amount of gas spent on the execution PageNFT.createComment function
    function comment(
        address from,
        address to,
        uint256 gas
    ) public payable override onlyCommentDeployer returns (uint256) {
        uint256 basicAmount = _calculateAmount(gas);
        uint256 treasuryAmount = _calculateTreasuryAmount(basicAmount);
        uint256 amount = basicAmount.div(2);
        _setBalance(from, _addBalance(from, amount));
        _setBalance(treasury, _addBalance(treasury, treasuryAmount));
        token.mint(to, amount += _refund(to));
        return basicAmount;
    }
    */
    /// @notice Returns WETH / USDT price from UniswapV3
    /// @return WETH / USDT price
    function getWETHUSDTPrice() public view override returns (uint256) {
        /*
        (uint160 sqrtPriceX96, , , , , , ) = wethusdtPool.slot0();
        uint256 price = uint256(sqrtPriceX96)
            .mul(sqrtPriceX96)
            .mul(10e18)
            .div(10e6)
            .div(2**192);
        return price;
        */
        return 3500;
    }

    /// @notice Returns USDT / PAGE price from UniswapV3
    /// @return USDT / PAGE price
    function getUSDTPAGEPrice() public view override returns (uint256) {
        /*
        (uint160 sqrtPriceX96, , , , , , ) = usdtpagePool.slot0();
        uint256 price = uint256(sqrtPriceX96)
            .mul(sqrtPriceX96)
            .div(10e18)
            .mul(10e6)
            .div(2**192);
        if (price > 100) {
            price = 100;
        }
        return price;
        */
        return 50;
    }

    /// @notice Returns USDT / PAGE price from UniswapV3
    /// @param _usdtpagePool UniswapV3Pool USDT / PAGE address from UniswapV3Factory
    function setUSDTPAGEPool(address _usdtpagePool) public override onlyOwner {
        usdtpagePool = IUniswapV3Pool(_usdtpagePool);
    }

    /// @notice Returns USDT / PAGE price from UniswapV3
    /// @param _wethusdtPool UniswapV3Pool USDT / PAGE address from UniswapV3Factory
    function setWETHUSDTPool(address _wethusdtPool) public override onlyOwner {
        wethusdtPool = IUniswapV3Pool(_wethusdtPool);
    }

    /// @notice Return amount from _balance and set 0
    /// @param _to Address of tokens holder
    /// @return Amount of PAGE tokens
    function _refund(address _to) private returns (uint256) {
        uint256 balance = _balances[_to];
        _balances[_to] = 0;
        return balance;
    }

    /// @notice Add amount to _balances
    /// @param _to Address to which to add
    /// @param _amount Amount that needs to add
    function _addBalance(address _to, uint256 _amount)
        private
        returns (uint256)
    {
        _balances[_to] = _balances[_to].add(_amount);
        return _balances[_to];
    }

    /// @notice Substraction amount from _balances
    /// @param _to Address to which to substraction
    /// @param _amount Amount that needs to substraction
    function _subBalance(address _to, uint256 _amount)
        private
        returns (uint256)
    {
        _balances[_to] = _balances[_to].sub(_amount);
        return _balances[_to];
    }

    /// @notice Set amount to _balances
    /// @param _to Address to which to set
    /// @param _amount Amount that needs to set
    function _setBalance(address _to, uint256 _amount) private {
        _balances[_to] = _amount;
    }

    /// @notice Returns gas multiplied by token's prices and gas price.
    /// @param _gas Comment author's address
    /// @return PAGE token's count
    function _calculateAmount(uint256 _gas) private view returns (uint256) {
        return
            _gas.mul(tx.gasprice).mul(getWETHUSDTPrice()).mul(
                getUSDTPAGEPrice()
            );
    }

    /// @notice Returns amount divided by treasury fee
    /// @param _amount Amount for dividing
    /// @return PAGE token's count
    function _calculateTreasuryAmount(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.div(10000).mul(treasuryFee);
    }
}
