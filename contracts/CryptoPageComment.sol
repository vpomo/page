// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMapUpgradeable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "./interfaces/ICryptoPageBank.sol";
import "./interfaces/ICryptoPageComment.sol";

// event Burn(address indexed _to, uint256 indexed _amount);
/// @title Contract for storage and interaction of comments for ERC721 tokens
/// @author Crypto.Page Team
/// @notice Contract designed to store comments of one specific token
/// @dev These contracts are deployed by the `CryptoPageCommentDeployer` contract
contract PageComment is Initializable {
    using SafeMathUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.UintToAddressMap;

    /// Stores all comments ids
    mapping(bytes32 => uint256[]) public commentsIdsArray;
    mapping(bytes32 => mapping(uint256 => Comment)) public commentsById;
    mapping(bytes32 => mapping(address => uint256[])) public commentsOf;
    mapping(bytes32 => CountersUpgradeable.Counter) private _totalLikes;
    mapping(address => EnumerableMapUpgradeable.UintToAddressMap)
        private commentsByERC721;

    struct Comment {
        uint256 id;
        address author;
        bytes32 ipfsHash; //This MUST be an base58 decoded hash. The reason of it is an IPFS hash consumes 46 bytes, which can't be stored at a single 32 bytes slot
        bool like;
        uint256 price;
    }

    IPageBank public bank;

    /// @notice Initial function
    /// @param _bank Address of our bank
    function initialize(address _bank) public initializer {
        bank = IPageBank(_bank);
    }

    /// @notice The event is emmited when creating a new comment
    /// @dev Emmited occurs in the _createComment function
    /// @param id Comment id
    /// @param author Commenth author
    /// @param ipfsHash Comment text
    /// @param like Comment reaction (like or dislike)
    /// @param price Price in PAGE tokens
    event NewComment(
        uint256 id,
        address author,
        bytes32 ipfsHash, // This MUST be an base58 decoded hash. The reason of it is an IPFS hash consumes 46 bytes, which can't be stored at a single 32 bytes slot
        bool like,
        uint256 price
    );

    /// @notice Create comment for any ERC721 Token
    /// @param ipfsHash IPFS hash
    /// @param like Positive or negative reaction to comment
    function createComment(
        IERC721Upgradeable nft,
        uint256 tokenId,
        bytes32 ipfsHash,
        bool like
    ) public returns (Comment memory comment) {
        uint256 gasBefore = gasleft();
        // require(msg.sender != address(0), "Address can't be null");
        //
        //
        //
        //
        //
        comment = _createComment(nft, tokenId, msg.sender, ipfsHash, like);
        uint256 gas = gasBefore - gasleft();
        uint256 price = bank.processMint(
            msg.sender,
            nft.ownerOf(tokenId),
            gas
        );
        commentsById[_getBytes32(address(nft), tokenId)][comment.id]
            .price = price; // bank.processMint(msg.sender, nft.ownerOf(tokenId), gas);
        emit NewComment(
            comment.id,
            comment.author,
            comment.ipfsHash,
            comment.like,
            comment.price
        );
        return comment;
    }

    /// @notice Return id's of all comments
    /// @return Array of Comment structs
    function getCommentsIds(IERC721Upgradeable nft, uint256 tokenId)
        public
        view
        returns (uint256[] memory)
    {
        return commentsIdsArray[_getBytes32(address(nft), tokenId)];
    }

    /// @notice Return comments by id's
    function getCommentsByIds(
        IERC721Upgradeable nft,
        uint256 tokenId,
        uint256[] memory ids
    ) public view returns (Comment[] memory comments) {
        require(ids.length > 0, "ids length must be more than zero");
        require(
            ids.length <=
                commentsIdsArray[_getBytes32(address(nft), tokenId)].length,
            "ids length must be less or equal commentsIdsArray"
        );

        comments = new Comment[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            require(
                ids[i] <=
                    commentsIdsArray[_getBytes32(address(nft), tokenId)].length,
                "No comment with this ID"
            );
            Comment storage comment = commentsById[
                _getBytes32(address(nft), tokenId)
            ][ids[i]];
            comments[i] = comment;
        }
        return comments;
    }

    /// @notice Return all comments
    function getComments(IERC721Upgradeable nft, uint256 tokenId)
        public
        view
        returns (Comment[] memory comments)
    {
        // Comment[] memory comments;
        if (commentsIdsArray[_getBytes32(address(nft), tokenId)].length > 0) {
            comments = getCommentsByIds(
                nft,
                tokenId,
                commentsIdsArray[_getBytes32(address(nft), tokenId)]
            );
        }
        // return comments;
    }

    /// @notice Return comment by id
    /// @return Comment struct
    function getCommentById(
        IERC721Upgradeable nft,
        uint256 tokenId,
        uint256 id
    ) public view returns (Comment memory) {
        require(
            id < commentsIdsArray[_getBytes32(address(nft), tokenId)].length,
            "No comment with this ID"
        );
        return commentsById[_getBytes32(address(nft), tokenId)][id];
    }

    /// @notice Return statistic
    /// @return total Count of comments
    /// @return likes Count of likes
    /// @return dislikes Count of dislikes
    function getStatistic(IERC721Upgradeable nft, uint256 tokenId)
        public
        view
        returns (
            uint256 total,
            uint256 likes,
            uint256 dislikes
        )
    {
        total = commentsIdsArray[_getBytes32(address(nft), tokenId)].length;
        likes = _totalLikes[_getBytes32(address(nft), tokenId)].current();
        dislikes = total.sub(likes);
    }

    /// @notice Return statistic with comments
    /// @return total Count of comments
    /// @return likes Count of likes
    /// @return dislikes Count of dislikes
    /// @return comments Array of Comment structs
    function getStatisticWithComments(IERC721Upgradeable nft, uint256 tokenId)
        public
        view
        returns (
            uint256 total,
            uint256 likes,
            uint256 dislikes,
            Comment[] memory comments
        )
    {
        (total, likes, dislikes) = getStatistic(nft, tokenId);
        comments = getComments(nft, tokenId);
    }

    /// @notice Return comments by author's address
    /// @param author Address of author
    /// @return Comments Array of Comment structs
    function getCommentsOf(
        IERC721Upgradeable nft,
        uint256 tokenId,
        address author
    ) public view returns (Comment[] memory) {
        // require(msg.sender != address(0), "Address can't be null");
        uint256[] memory ids = commentsOf[_getBytes32(address(nft), tokenId)][
            author
        ];
        Comment[] memory comments;
        if (ids.length > 0) {
            comments = getCommentsByIds(nft, tokenId, ids);
        }
        return comments;
    }

    /// @notice Create comment for any ERC721 Token
    /// @param _author Author of comment
    /// @param _ipfsHash IPFS hash
    /// @param _like Positive or negative reaction to comment
    function _createComment(
        IERC721Upgradeable nft,
        uint256 tokenId,
        address _author,
        bytes32 _ipfsHash,
        bool _like
    ) internal returns (Comment memory) {
        uint256 id = commentsIdsArray[_getBytes32(address(nft), tokenId)]
            .length;
        commentsIdsArray[_getBytes32(address(nft), tokenId)].push(id);
        commentsOf[_getBytes32(address(nft), tokenId)][msg.sender].push(id);
        commentsById[_getBytes32(address(nft), tokenId)][id] = Comment(
            id,
            _author,
            _ipfsHash,
            _like,
            0
        );
        if (_like) {
            CountersUpgradeable.Counter storage counter = _totalLikes[
                _getBytes32(address(nft), tokenId)
            ];
            counter.increment();
        }
        return commentsById[_getBytes32(address(nft), tokenId)][id];
    }

    function _getBytes32(address nft, uint256 tokenId)
        private
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(nft, tokenId));
    }

    function calculateCommentsReward(address nft, uint256 tokenId)
        public
        view
        returns (uint256 reward)
    {
        Comment[] memory comments = getComments(IERC721Upgradeable(nft), tokenId);
        for (uint256 i = 0; i < comments.length; i++) {
            Comment memory comment = comments[i];
            // If author of the comment is not sender
            // Need to calculate 45% of comment.price
            // This is an equivalent reward for comment
            if (comment.author != IERC721Upgradeable(nft).ownerOf(tokenId)) {
                reward = reward.add(comment.price).mul(2); //.div(100).mul(45));
            }
        }
    }
}
