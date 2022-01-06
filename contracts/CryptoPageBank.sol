// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import "./interfaces/ICryptoPageBank.sol";
import "./interfaces/ICryptoPageToken.sol";
import "./interfaces/ICryptoPageCommentDeployer.sol";
import "./interfaces/ICryptoPageNFT.sol";

contract PageBank is OwnableUpgradeable, AccessControlUpgradeable, IPageBank {
    mapping(address => uint256) private _balances;

    using SafeMathUpgradeable for uint256;

    address public treasury;
    uint256 public fee;

    IPageToken public token;
    IPageNFT public nft;
    IPageCommentDeployer public commentDeployer;
    IUniswapV3Pool public usdtpagePool;
    IUniswapV3Pool public wethusdtPool;

    bytes32 private constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 private constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 private constant TRANSFERER_ROLE = keccak256("TRANSFERER_ROLE");
    bytes32 private constant COMMENTER_ROLE = keccak256("COMMENTER_ROLE");

    /// @notice Initial function
    /// @param _treasury Address of our treasury
    /// @param _fee Percent of treasury fee (1000 is 10%; 100 is 1%; 10 is 0.1%)
    function initialize(
        address _treasury,
        address _nft,
        address _commentMinter,
        uint256 _fee
    ) public initializer {
        __Ownable_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        treasury = _treasury;
        fee = _fee;
        nft = IPageNFT(_nft);
        commentDeployer = IPageCommentDeployer(_commentMinter);
    }

    /// @notice Function for calling from PageNFT.safeMint
    /// @param to Address for minting
    /// @param gas Amount of gas spent on the execution PageNFT.safeMint function
    function mint(address to, uint256 gas)
        public
        payable
        override
        onlyRole(MINTER_ROLE)
        returns (uint256)
    {
        uint256 amount = _calculateAmount(gas);
        uint256 treasuryAmount = _calculateTreasuryAmount(amount);
        token.mint(to, amount);
        _setBalance(treasury, _addBalance(treasury, treasuryAmount));
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
    ) public payable override onlyRole(MINTER_ROLE) returns (uint256) {
        require(_msgSender() == from, "Only for owner");
        uint256 amount = _calculateAmount(gas);
        uint256 treasuryAmount = _calculateTreasuryAmount(amount);
        amount = amount.div(2);
        token.mint(to, amount);
        _setBalance(treasury, _addBalance(treasury, treasuryAmount));
        _setBalance(from, _addBalance(from, amount));
        return amount;
    }

    /// @notice Function for calling from PageNFT.safeBurn
    /// @param to Owner's address of PAGE.NFT token
    /// @param gas Amount of gas spent on the execution PageNFT.safeBurn function
    function burn(
        address to,
        uint256 gas,
        uint256 burnPrice
    ) public payable override onlyRole(BURNER_ROLE) {
        uint256 amount = _calculateAmount(gas);
        burnPrice = _calculateAmount(burnPrice);
        amount = burnPrice.add(amount);
        require(token.balanceOf(_msgSender()) >= amount, "not enought balance");
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
    ) public payable override onlyRole(TRANSFERER_ROLE) {
        uint256 amount = _calculateAmount(gas);
        uint256 treasuryAmount = _calculateTreasuryAmount(amount);
        amount = amount.div(2);
        _setBalance(to, _addBalance(to, amount));
        _setBalance(treasury, _addBalance(treasury, treasuryAmount));
        token.mint(from, amount);
    }

    /// @notice Function for calling from PageNFT.createComment
    /// @param from Comment author's address
    /// @param to Recipient address
    /// @param gas Amount of gas spent on the execution PageNFT.createComment function
    function comment(
        address from,
        address to,
        uint256 gas
    ) public payable override onlyRole(COMMENTER_ROLE) returns (uint256) {
        uint256 basicAmount = _calculateAmount(gas);
        uint256 treasuryAmount = _calculateTreasuryAmount(basicAmount);
        uint256 amount = basicAmount.div(2);
        _setBalance(from, _addBalance(from, amount));
        _setBalance(treasury, _addBalance(treasury, treasuryAmount));
        token.mint(to, amount);
        return basicAmount;
    }

    /// @notice Returns WETH / USDT price from UniswapV3
    /// @return WETH / USDT price
    function getWETHUSDTPrice() public view override returns (uint256) {
        (uint160 sqrtPriceX96, , , , , , ) = wethusdtPool.slot0();
        uint256 price = uint256(sqrtPriceX96)
            .mul(sqrtPriceX96)
            .mul(10e18)
            .div(10e6)
            .div(2**192);
        return price;
    }

    /// @notice Returns USDT / PAGE price from UniswapV3
    /// @return USDT / PAGE price
    function getUSDTPAGEPrice() public view override returns (uint256) {
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

    /// @notice Add amount to _balances
    /// @param _to Address to which to add
    /// @param _amount Amount that needs to add
    function _addBalance(address _to, uint256 _amount)
        public
        override
        returns (uint256)
    {
        _balances[_to] += _amount;
        return _balances[_to];
    }

    /// @notice Substraction amount from _balances
    /// @param _to Address to which to substraction
    /// @param _amount Amount that needs to substraction
    function _subBalance(address _to, uint256 _amount)
        public
        override
        returns (uint256)
    {
        _balances[_to] += _amount;
        return _balances[_to];
    }

    /// @notice Set amount to _balances
    /// @param _to Address to which to set
    /// @param _amount Amount that needs to set
    function _setBalance(address _to, uint256 _amount) public override {
        _balances[_to] = _amount;
    }

    /// @notice Returns gas multiplied by token's prices and gas price.
    /// @param gas Comment author's address
    /// @return PAGE token's count
    function _calculateAmount(uint256 gas)
        public
        view
        override
        returns (uint256)
    {
        return
            gas.mul(tx.gasprice).mul(getWETHUSDTPrice()).mul(
                getUSDTPAGEPrice()
            );
    }

    /// @notice Returns amount divided by treasury fee
    /// @param amount Amount for dividing
    /// @return PAGE token's count
    function _calculateTreasuryAmount(uint256 amount)
        private
        view
        returns (uint256)
    {
        return amount.div(10000).mul(fee);
    }
}