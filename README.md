# ERC-721 Delatage Registry

## Summary

A minimally simple registry that allows for NFT owners to be able to delegate their ERC-721 tokens without having to hand over full control of their NFTs. A `delegate` is an address that is able to enact some functionality that has been built on top of this contract without having the ability to transfer the delegated NFT.

-   A delegate can sign data off-chain or submit a transaction on-chain to prove ownership by proxy without being able to transfer the delegated NFT
-   Only the current NFT owner can set the delegate address
-   There can only ever be one delegate at a time for an NFT

<br/>

## Potential Use Cases

Ideally this registry is simple and flexible enough that many different types of fuctionality could be built on top.

Early possible use cases include:

-   Proving Ownership of Custodial/Cold Storage NFTs
-   NFT Renting
-   Event Check In

<br/>

### Proving Ownership of Custodial NFTs

As the value of NFTs increases over time, owners will seek out solutions to help custody their expensive NFTs. However, now that the assets are being held by a third party it makes it much more difficult to verify who owns what. You are no longer able to sign an off-chain message proving you own an asset if it is being held in a custodial address.

Problem:

Your rare NFT, after years of holding, is now worth to over 100 ETH and you don't feel comfortable self custody anymore. You then pay a third-party and they take custody of the asset. A few weeks later you learn that there is an NFT that is airdropped to all the holders of the NFT you locked in custody. As a result, you are unable to claim your airdropped NFT in the time since the valuable NFT you need is being held in a custodial service.

Solution:

An owner registers an address that they own as a delegate and then passes the NFT off to the custodian. Now anytime they need to prove ownership of an NFT that is in custody; the service, smart contract, or middleware that is validating ownership checks if the off-chain signature or on-chain transaction came from the delegate address and allows them to claim the airdropped NFT.

<br/>

### NFT Renting

The utility of NFTs will increase over time. Certain owners will want to rent out their assets to parties that are willing to pay to access to said utility but can't afford to purchase the NFT outright. However, renting out an NFT could be dangerous because if you transfer the NFT to the renter then you are trusting them not to sell it at a profit on the market since the market price will be higher than the rental price. Therefore, it is necessary to be able to create an air gap between the renter being able to access the utility of an NFT and the ability for the renter to transfer the NFT.

Problem:

You own a game NFT that is for a plot of land which has a lot of mineral deposits. You strike up a deal to rent out the mining rights of this land for 10 ETH per month. You find a renter, get your 10 ETH upfront, and then transfer the NFT to the renter so that they can start mining. However, because the land is worth 1000 ETH they immediately run off with the NFT since they have full control.

Solution:

An NFT rental contract is built on top of this registry and the game software that is validating ownership checks if the off-chain signature or on-chain transaction came from a valid delegate address. In this scenario, the renter was able to access the utility of the land NFT but was never given access to transfer the NFT.

<br/>

### Event Check In

Token gated events are growing in popularity. These events sometimes require that an owner sign a message at the door to prove they own the correct NFT to get in. However, the issue is that the user needs to have their expensive NFTs in a mobile wallet with them when they go to the event. This creates unnecessary risk and might not be possible if the NFT is being held by a custodian.

Problem:

You are going to large event in a major city. The event requires that you have your 100 ETH NFT on your phone when you check into the event to get in. Transferring your valuable NFT to a mobile device and then walking around with in a major city is less than ideal from a safety standpoint.

Solution:

You register an empty address in your mobile wallet as a delegate. Then when you arrive at the event you can produce a signature from the empty mobile wallet and the event can check if that address is a delegate to a valid NFT. This method is safer since you don't need to carry around expensive NFTs on your person or you don't need to get the NFT from a custodian if you set up a delegate address before you handed over the NFT.

<br/>

## Contract Interface

### getDelegate

Returns the delegate address for a given ERC-721 NFT.

```
function getDelegate(address _tokenAddress, uint _tokenId)
```

### setDelegate

Sets the delegate address for a given ERC-721 NFT.

```
function setDelegate(
    address _tokenAddress,
    uint _tokenId,
    address _delegateAddress
)
```

### setDelegateWithSig

Sets the delegate address for a given ERC-721 NFT with a signature from the owner.

```
function setDelegateWithSig(
    address _tokenAddress,
    uint _tokenId,
    address _delegateAddress,
    bytes memory _signature
)
```

### DelegateSet Event

Emitted whenever a new delegate address is set.

```
event DelegateSet(address tokenAddress, uint tokenId, address owner, address delegateAddress);
```
