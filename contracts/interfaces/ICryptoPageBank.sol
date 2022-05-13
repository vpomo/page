// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

interface IPageBank {

    function version() external pure returns (string memory);

    function definePostFeeForNewCommunity(uint256 communityId) external returns(bool);

    function readPostFee(uint256 communityId) external view returns(
        uint64 createPostOwnerFee,
        uint64 createPostCreatorFee,
        uint64 removePostOwnerFee,
        uint64 removePostCreatorFee
    );

    function defineCommentFeeForNewCommunity(uint256 communityId) external returns(bool);

    function readCommentFee(uint256 communityId) external view returns(
        uint64 createCommentOwnerFee,
        uint64 createCommentCreatorFee,
        uint64 removeCommentOwnerFee,
        uint64 removeCommentCreatorFee
    );

    function updatePostFee(
        uint256 communityId,
        uint64 newCreatePostOwnerFee,
        uint64 newCreatePostCreatorFee,
        uint64 newRemovePostOwnerFee,
        uint64 newRemovePostCreatorFee
    ) external;

    function updateCommentFee(
        uint256 communityId,
        uint64 newCreateCommentOwnerFee,
        uint64 newCreateCommentCreatorFee,
        uint64 newRemoveCommentOwnerFee,
        uint64 newRemoveCommentCreatorFee
    ) external;


    function mintTokenForNewPost(
        uint256 communityId,
        address owner,
        address creator,
        uint256 gas
    ) external returns (uint256 amount);

    function mintTokenForNewComment(
        uint256 communityId,
        address owner,
        address creator,
        uint256 gas
    ) external returns (uint256 amount);

    function addUpDownActivity(
        uint256 communityId,
        address postCreator,
        bool isUp
    ) external;

    function burnTokenForPost(
        uint256 communityId,
        address owner,
        address creator,
        uint256 gas
    ) external returns (uint256 amount);

    function burnTokenForComment(
        uint256 communityId,
        address owner,
        address creator,
        uint256 gas
    ) external returns (uint256 amount);

    function withdraw(uint256 amount) external;

    function addBalance(uint256 amount) external;

    function setPriceForPrivacyAccess(uint256 communityId, uint256 newValue) external;

    function transferFromCommunity(uint256 communityId, uint256 amount, address wallet) external returns(bool);

    function payForPrivacyAccess(uint256 amount, uint256 communityId) external;

    function balanceOf(address user) external view returns (uint256);

    function balanceOfCommunity(uint256 communityId) external view returns (uint256);

    function getWETHPagePriceFromPool() external view returns (uint256 price);

    function getWETHPagePrice() external view returns (uint256 price);

    function setDefaultFee(uint256 index, uint64 newValue) external;

    function setMintGasAmount(uint256 newValue) external;

    function setBurnGasAmount(uint256 newValue) external;

    function setWETHPagePool(address newWethPagePool) external;

    function setStaticWETHPagePrice(uint256 price) external;

    function setPriceChangePercent(uint256 percent) external;

    function setToken(address newToken) external;

    function setTreasuryFee(uint256 newTreasuryFee ) external;

    function isPrivacyAvailable(address user, uint256 communityId) external view returns(bool);

}
