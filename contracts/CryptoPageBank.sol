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
    bytes32 public constant UPDATER_FEE_ROLE = keccak256("UPDATER_FEE_ROLE");
    bytes32 public constant DEFINE_FEE_ROLE = keccak256("DEFINE_FEE_ROLE");

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
        uint64 createPostOwnerFee;
        uint64 createPostCreatorFee;
        uint64 removePostOwnerFee;
        uint64 removePostCreatorFee;

        uint64 createCommentOwnerFee;
        uint64 createCommentCreatorFee;
        uint64 removeCommentOwnerFee;
        uint64 removeCommentCreatorFee;
    }

    mapping(uint256 => CommunityFee) private communityFee;

    uint64 public defaultCreatePostOwnerFee = 4500;
    uint64 public defaultCreatePostCreatorFee = 4500;
    uint64 public defaultRemovePostOwnerFee = 0;
    uint64 public defaultRemovePostCreatorFee = 9000;

    uint64 public defaultCreateCommunityOwnerFee = 4500;
    uint64 public defaultCreateCommunityCreatorFee = 4500;
    uint64 public defaultRemoveCommunityOwnerFee = 0;
    uint64 public defaultRemoveCommunityCreatorFee = 9000;

    // Storage balance per address
    mapping(address => uint256) private _balances;

    event Withdraw(address indexed user, uint256 amount);
    event AddedBalance(address indexed user, uint256 amount);

    event MintForPost(uint256 indexed communityId, address owner, address creator, uint256 amount);
    event MintForComment(uint256 indexed communityId, address owner, address creator, uint256 amount);

    event BurnForPost(uint256 indexed communityId, address owner, address creator, uint256 amount);
    event BurnForComment(uint256 indexed communityId, address owner, address creator, uint256 amount);

    event UpdatePostFee(
        uint256 indexed communityId,
        uint64 newCreatePostOwnerFee,
        uint64 newCreatePostCreatorFee,
        uint64 newRemovePostOwnerFee,
        uint64 newRemovePostCreatorFee
    );
    event UpdateCommentFee(
        uint256 indexed communityId,
        uint64 newCreateCommentOwnerFee,
        uint64 newCreateCommentCreatorFee,
        uint64 newRemoveCommentOwnerFee,
        uint64 newRemoveCommentCreatorFee
    );

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

    //TODO setter for default variable
    function definePostFeeForNewCommunity(uint256 communityId) public onlyRole(MINTER_ROLE) returns(bool) {
        CommunityFee storage fee = communityFee[communityId];

        fee.createPostOwnerFee = defaultCreatePostOwnerFee;
        fee.createPostCreatorFee = defaultCreatePostCreatorFee;
        fee.removePostOwnerFee = defaultRemovePostOwnerFee;
        fee.removePostCreatorFee = defaultRemovePostCreatorFee;
        return true;
    }

    //TODO setter for default variable
    function defineCommentFeeForNewCommunity(uint256 communityId) public onlyRole(MINTER_ROLE) returns(bool) {
        CommunityFee storage fee = communityFee[communityId];

        fee.createCommentOwnerFee = defaultCreateCommentOwnerFee;
        fee.createCommentCreatorFee = defaultCreateCommentCreatorFee;
        fee.removeCommentOwnerFee = defaultRemoveCommentOwnerFee;
        fee.removeCommentCreatorFee = defaultRemoveCommentCreatorFee;
        return true;
    }

    function updatePostFee(
        uint256 communityId,
        uint64 newCreatePostOwnerFee,
        uint64 newCreatePostCreatorFee,
        uint64 newRemovePostOwnerFee,
        uint64 newRemovePostCreatorFee
    ) public onlyRole(UPDATER_FEE_ROLE) {
        CommunityFee storage fee = communityFee[communityId];
        fee.createPostOwnerFee = newCreatePostOwnerFee;
        fee.createPostCreatorFee = newCreatePostCreatorFee;
        fee.removePostOwnerFee = newRemovePostOwnerFee;
        fee.removePostCreatorFee = newRemovePostCreatorFee;

        emit UpdatePostFee(communityId,
            newCreatePostOwnerFee,
            newCreatePostCreatorFee,
            newRemovePostOwnerFee,
            newRemovePostCreatorFee
        );
    }

    function updateCommentFee(
        uint256 communityId,
        uint64 newCreateCommentOwnerFee,
        uint64 newCreateCommentCreatorFee,
        uint64 newRemoveCommentOwnerFee,
        uint64 newRemoveCommentCreatorFee
    ) public onlyRole(UPDATER_FEE_ROLE) {
        CommunityFee storage fee = communityFee[communityId];
        fee.createCommentOwnerFee = newCreateCommentOwnerFee;
        fee.createCommentCreatorFee = newCreateCommentCreatorFee;
        fee.removeCommentOwnerFee = newRemoveCommentOwnerFee;
        fee.removeCommentCreatorFee = newRemoveCommentCreatorFee;

        emit UpdateCommentFee(communityId,
            newCreateCommentOwnerFee,
            newCreateCommentCreatorFee,
            newRemoveCommentOwnerFee,
            newRemoveCommentCreatorFee
        );
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

        emit MintForPost(communityId, owner, creator, amount);
    }

    function mintTokenForNewComment(
        uint256 communityId,
        address owner,
        address creator,
        uint256 gas
    ) public override onlyRole(MINTER_ROLE) returns (uint256 amount) {
        amount = convertGasToTokenAmount(gas + FOR_MINT_GAS_AMOUNT);

        mintUserPageToken(owner, amount, communityFee[communityId].createCommentOwnerFee);
        mintUserPageToken(creator, amount, communityFee[communityId].createCommentCreatorFee);
        mintTreasuryPageToken(amount);

        emit MintForComment(communityId, owner, creator, amount);
    }

    /// @notice Calculate and call burn
    /// @param receiver The address on which the tokens burn
    /// @param gas The amount of gas spent on the function call
    /// @param commentsReward Reward for comments in PAGE tokens
    function burnTokenForPost(
        uint256 communityId,
        address owner,
        address creator,
        uint256 gas
    ) public override onlyRole(BURNER_ROLE) returns (uint256 amount) {
        amount = convertGasToTokenAmount(gas + FOR_BURN_GAS_AMOUNT);

        burnUserPageToken(owner, amount, communityFee[communityId].removePostOwnerFee);
        burnUserPageToken(creator, amount, communityFee[communityId].removePostCreatorFee);

        emit BurnForPost(communityId, owner, creator, amount);
    }

    function burnTokenForComment(
        uint256 communityId,
        address owner,
        address creator,
        uint256 gas
    ) public override onlyRole(BURNER_ROLE) returns (uint256 amount) {
        amount = convertGasToTokenAmount(gas + FOR_BURN_GAS_AMOUNT);

        burnUserPageToken(owner, amount, communityFee[communityId].removeCommentOwnerFee);
        burnUserPageToken(creator, amount, communityFee[communityId].removeCommentCreatorFee);

        emit BurnForComment(communityId, owner, creator, amount);
    }

    /// @notice Withdraw amount from the bank
    function withdraw(uint256 amount) public override {
        require(_balances[_msgSender()] >= amount, "Not enough balance");
        _balances[_msgSender()] -= amount;
        token.mint(_msgSender(), amount);
        emit Withdraw(_msgSender(), amount);
    }

    function addBalance(uint256 amount) public override {
        require(amount > 0, "Wrong amount");
        require(token.transferFrom(_msgSender(), address(this), amount));
        _balances[_msgSender()] += amount;
        emit AddedBalance(_msgSender(), amount);
    }

    /// @notice Bank balance of the sender's address
    function balanceOf(address user) public view override returns (uint256) {
        return _balances[user];
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

    function setPostDefaultFee(uint256 index, uint256 newValue) public override onlyOwner {
        if (index == 0) {
            emit SetDefaultFee(index, defaultCreatePostOwnerFee, newValue);
            defaultCreatePostOwnerFee = newValue;
        }
        if (index == 1) {
            emit SetDefaultFee(index, defaultCreatePostCreatorFee, newValue);
            defaultCreatePostCreatorFee = newValue;
        }
        if (index == 2) {
            emit SetDefaultFee(index, defaultRemovePostOwnerFee, newValue);
            defaultRemovePostOwnerFee = newValue;
        }
        if (index == 3) {
            emit SetDefaultFee(index, defaultRemovePostCreatorFee, newValue);
            defaultRemovePostCreatorFee = newValue;
        }
        if (index == 4) {
            emit SetDefaultFee(index, defaultCreateCommunityOwnerFee, newValue);
            defaultCreateCommunityOwnerFee = newValue;
        }
        if (index == 5) {
            emit SetDefaultFee(index, defaultCreateCommunityCreatorFee, newValue);
            defaultCreateCommunityCreatorFee = newValue;
        }
        if (index == 6) {
            emit SetDefaultFee(index, defaultRemoveCommunityOwnerFee, newValue);
            defaultRemoveCommunityOwnerFee = newValue;
        }
        if (index == 7) {
            emit SetDefaultFee(index, defaultRemoveCommunityCreatorFee, newValue);
            defaultRemoveCommunityCreatorFee = newValue;
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

    function burnUserPageToken(address user, uint256 amount, uint256 userFee) private {
        require(user != address(0), "PageBank: wrong user address");

        uint256 userAmount = amount * userFee / ALL_PERCENT;
        token.burn(address(this), userAmount);
        _balances[user] -= userAmount;
    }
}
