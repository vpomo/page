#### Description of the project.

The project is intended for users to post messages in a decentralized system.
Creation and deletion of data is associated with a change in the balance of `PAGE` tokens and `NFT` tokens `PAGE` on users' wallets
Users can join communities. Community - a group of users united by some common interests.

Communities are created first. Each community can create their own posts and comments on posts.
Creating a post automatically entails the creation of a `NFT` token. Every post and comment has a wallet address
user - the creator and the wallet address of the user - owner. `NFT` tokens (posts) can be transferred
from one user to another. But giving `NFT` to someone just isn't possible.
It is possible provided that the user - the recipient of the `NFT` token before accepting the token gave approve() for this operation.

Upvotes and downvotes come with comments on posts. upvotes, downvotes do not exist without comments.
For one comment there can be only one thing: either upvotes or downvotes.

Community members choose and appoint their own moderators.
Only a moderator can delete comments created in the Community.
The procedure for appointing a moderator or removing him is carried out through the voting procedure of the members of this
community using the `PageVoteForCommon` contract.
When voting, the number of `PAGE` tokens on the wallet of this user and on his balance is taken into account
account in the `PageBank` contract.
These values ​​are summed up and give weight to the voice. So `PAGE` tokens are also management tokens.

By default, in Community, only the owner of that post can delete a post.
The comment can be removed by a community moderator.

Posts and comments have a visibility property. It is enabled by default.
But a community moderator can manage this property.

Communities can be active or inactive. Comments and posts from inactive communities cannot be read, deleted or created new ones.
Community activity can only be changed by voting members of that community.

Private access to the Community can be enabled by voting members of the Community through the `PageVoteForEarn` contract.
Community members pay for private access in `PAGE` tokens through the `PageBank` contract.
The tokens earned by the Community for private access by voting can be withdrawn to any user's wallet.

Creating a post entails a mint of new `NFT` token and a mint of `PAGE` tokens.
The number of `PAGE` tokens is equivalent in value to the amount of ether spent on gas for this operation.
The current value of the token is taken from the `ETH-PAGE` pool created on Uniswap v3.
Creating a comment also triggers a mint of `PAGE` tokens to offset gas costs. But `NFT` does not mint in this case.
To delete a post or comment, you need to spend a certain number of `PAGE` tokens.
During these operations, the distribution of `PAGE` tokens concerns 3 wallets: `Treasury Wallet`, `owner` and `creator`.
Tokens are distributed to these wallets not evenly, but as a percentage.
The value of these percentages can be changed by community members by voting through the `PageVoteForCommon` contract.
When you create a new community, default values ​​are automatically assigned.

When contracts are deployed, an initial emission of 50,000,000 `PAGE` tokens is made on the `Treasury Wallet`.


#### Interaction scheme.

<p align="center">
  <img src="https://github.com/page-token/page/blob/develop/docs/page-token.jpg" width="800" alt="Page token" />
</p>
