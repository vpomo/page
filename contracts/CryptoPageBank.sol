// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@uniswap/contracts/interfaces/IUniswapV3Pool.sol";
import "@openzeppelin/contracts/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/access/AccessControlUpgradeable.sol";

import "./interfaces/ICryptoPageBank.sol";
import "./interfaces/ICryptoPageToken.sol";

/// @title The contract calculates amount and mint / burn PAGE tokens
/// @author Crypto.Page Team
/// @notice
/// @dev 
contract PageBank is
    Initializable,
    OwnableUpgradeable,
    AccessControlUpgradeable,
    IPageBank
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    uint256 public FOR_MINT_GAS_AMOUNT = 2800;
    uint256 public FOR_BURN_GAS_AMOUNT = 2800;

    uint256 public staticUSDTPAGEPrice = 60;
    uint256 public staticWETHUSDTPrice = 3600;

    /// Address of Crypto.Page treasury
    address public treasury;
    /// Address of CryptoPageNFT contract
    address public nft;
    /// Address of CryptoPageCommentDeployer contract
    address public commentDeployer;

    uint256 public ALL_PERCENT = 10000;
    /// Treasury fee (1000 is 10%, 100 is 1% 10 is 0.1%)
    uint256 public treasuryFee = 1000;

    /// CryptoPageToken interface
    IPageToken public token;
    // UniswapV3Pool interface for USDT / PAGE pool
    IUniswapV3Pool private usdtpagePool;
    // UniswapV3Pool interface for WETH / USDT pool
    IUniswapV3Pool private wethusdtPool;

    struct CommunityFee {
        uint256 createPostOwnerFee;
        uint256 createPostCreatorFee;

        uint256 removePostOwnerFee;
        uint256 removePostCreatorFee;
    }
    mapping(uint256 => CommunityFee) private communityFee;
    uint256 public defaultCreatePostOwnerFee = 4500;
    uint256 public defaultCreatePostCreatorFee = 4500;
    uint256 public defaultRemovePostOwnerFee = 0;
    uint256 public defaultRemovePostCreatorFee = 9000;


    // Storage balance per address
    mapping(address => uint256) private _balances;

    event Withdraw(address indexed _to, uint256 indexed _amount);
    event Deposit(address indexed _to, uint256 indexed _amount);
    event Burn(address indexed _to, uint256 indexed _amount);

    event SetStaticWETHUSDTPrice(uint256 indexed _price);
    event SetStaticUSDTPAGEPrice(uint256 indexed _price);
    event SetToken(address indexed _token);
    event SetWETHUSDTPool(address indexed _pool);
    event SetUSDTPAGEPool(address indexed _pool);

    /// @notice Initial function
    /// @param _treasury Address of our treasury
    /// @param _admin Address of admin
    /// @param _treasuryFee Percent of treasury fee (1000 is 10%; 100 is 1%; 10 is 0.1%)
    function initialize(address _treasury, address _admin)
        public
        initializer
    {
        __Ownable_init();
        require(_treasury != address(0), "PageBank: wrong address");
        require(_admin != address(0), "PageBank: wrong address");
        treasury = _treasury;
    }

    //TODO: access denied
    //TODO setter for default variable
    function defineFeeForNewCommunity(uint256 communityId) public {
        CommunityFee storage fee = communityFee[communityId];
        fee.createPostOwnerFee = defaultCreatePostOwnerFee;
        fee.createPostCreatorFee = defaultCreatePostCreatorFee;
        fee.removePostOwnerFee = defaultRemovePostOwnerFee;
        fee.removePostCreatorFee = defaultRemovePostCreatorFee;
    }

    //TODO: access denied
    function updateFeeCommunity(uint256 communityId, uint256 newCreatePostOwnerFee, uint256 newCreatePostCreatorFee) public {
        CommunityFee storage fee = communityFee[communityId];
        fee.createPostOwnerFee = newCreatePostOwnerFee;
        fee.createPostCreatorFee = newCreatePostCreatorFee;
        fee.removePostOwnerFee =
    }


    /// @notice Calculate and call burn
    /// @param owner
    /// @param creator The creator address
    /// @param gas Gas
    function mintTokenForNewPost(
        uint256 communityId,
        address owner,
        address creator,
        uint256 gas
    ) public override onlyRole(MINTER_ROLE) returns (uint256 amount) {
        amount = convertGasToTokenAmount(gas + FOR_MINT_GAS_AMOUNT);

        mintUserPageToken(owner, amount, communityFee[communityId].createPostOwnerFee);
        mintUserPageToken(creator, amount, communityFee[communityId].createPostCreatorFee);
        mintTreasuryPageToken(amount);
    }

    /// @notice Calculate and call burn
    /// @param receiver The address on which the tokens burn
    /// @param gas The amount of gas spent on the function call
    /// @param commentsReward Reward for comments in PAGE tokens
    function processBurn(
        uint256 communityId,
        address owner,
        address creator,
        uint256 gas
    ) public override onlyRole(BURNER_ROLE) returns (uint256 amount) {
        amount = convertGasToTokenAmount(gas + FOR_BURN_GAS_AMOUNT);

        burnUserPageToken(owner, amount, communityFee[communityId].createPostOwnerFee);
        burnUserPageToken(creator, amount, communityFee[communityId].createPostCreatorFee);
        mintTreasuryPageToken(amount);
    }

    /// @notice Withdraw amount from the bank
    function withdraw(uint256 amount) public override {
        require(_balances[_msgSender()] >= amount, "Not enough balance");
        _balances[_msgSender()] -= amount;
        token.mint(_msgSender(), amount);
        emit Withdraw(_msgSender(), amount);
    }

    /// @notice Bank balance of the sender's address
    function balanceOf() public view override returns (uint256) {
        return _balances[_msgSender()];
    }

    function getWETHUSDTPriceFromPool()
        external
        view
        override
        returns (uint256 price)
    {
        (uint160 sqrtPriceX96, , , , , , ) = wethusdtPool.slot0();
        price = uint256(sqrtPriceX96)
            .mul(sqrtPriceX96)
            .div(10e18)
            .mul(10e6)
            .div(2**192);
    }

    function getUSDTPAGEPriceFromPool()
        external
        view
        override
        returns (uint256 price)
    {
        (uint160 sqrtPriceX96, , , , , , ) = usdtpagePool.slot0();
        price = uint256(sqrtPriceX96)
            .mul(sqrtPriceX96)
            .div(10e6)
            .mul(10e18)
            .div(2**192);
    }

    /// @notice Returns WETH / USDT price from UniswapV3Pool
    function getWETHUSDTPrice() public view override returns (uint256 price) {
        try IPageBank(this).getWETHUSDTPriceFromPool() returns (
            uint256 _price
        ) {
            price = _price;
        } catch {
            price = staticWETHUSDTPrice;
        }
        if (price == 0) {
            price = staticWETHUSDTPrice;
        }
    }

    /// @notice Returns USDT / PAGE price from UniswapV3Pool
    function getUSDTPAGEPrice() public view override returns (uint256 price) {
        try IPageBank(this).getUSDTPAGEPriceFromPool() returns (
            uint256 _price
        ) {
            price = _price;
        } catch {
            price = staticUSDTPAGEPrice;
        }
        if (price == 0) {
            price = staticUSDTPAGEPrice;
        }
        if (price > 100) {
            price = 100;
        }
    }

    /// @notice Returns USDT / PAGE price from UniswapV3
    /// @param _usdtpagePool UniswapV3Pool USDT / PAGE address from UniswapV3Factory
    function setUSDTPAGEPool(address _usdtpagePool) public override onlyOwner {
        usdtpagePool = IUniswapV3Pool(_usdtpagePool);
        emit SetUSDTPAGEPool(_usdtpagePool);
    }

    /// @notice Returns USDT / PAGE price from UniswapV3
    /// @param _wethusdtPool UniswapV3Pool USDT / PAGE address from UniswapV3Factory
    function setWETHUSDTPool(address _wethusdtPool) public override onlyOwner {
        wethusdtPool = IUniswapV3Pool(_wethusdtPool);
        emit SetWETHUSDTPool(_wethusdtPool);
    }

    /// @notice Returns USDT / PAGE price from UniswapV3
    function setStaticUSDTPAGEPrice(uint256 _price) public override onlyOwner {
        staticUSDTPAGEPrice = _price;
        emit SetStaticUSDTPAGEPrice(_price);
    }

    /// @notice Returns USDT / PAGE price from UniswapV3
    function setStaticWETHUSDTPrice(uint256 _price) public override onlyOwner {
        staticWETHUSDTPrice = _price;
        emit SetStaticWETHUSDTPrice(_price);
    }

    function setToken(address _address) public override onlyOwner {
        token = IPageToken(_address);
        emit SetToken(_address);
    }

    /// @notice Returns gas multiplied by token's prices and gas price.
    /// @param _gas Comment author's address
    /// @return PAGE token's count
    function convertGasToTokenAmount(uint256 _gas) private view returns (uint256) {
        return _gas * tx.gasprice * getWETHUSDTPrice() * getUSDTPAGEPrice();
    }

    function mintTreasuryPageToken(uint256 amount) private {
        require(treasury != address(0), "PageBank: wrong treasury address");
        token.mint(treasury, amount * treasuryFee / ALL_PERCENT);
    }

    function mintUserPageToken(address user, uint256 amount, uint256 userFee) private {
        require(user != address(0), "PageBank: wrong user address");

        uint256 userAmount = amount * userFee / ALL_PERCENT;
        token.mint(address(this), userAmount);
        _balances[user] += userAmount;
    }
}
