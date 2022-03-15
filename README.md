# ERC-721 Delatage Registry

## Summary

---

A minimally simple registry that allows for NFT owners to be able to delegate their ERC-721 tokens without having to hand over full control of an NFT. A `delegate` is an address that is able to enact some functionality that has been built on top of this contract without having the ability to actually transfer the delegated NFT.

-   A delegate is able to sign data offchain or submit a transaction onchain to prove ownership by proxy without being able to transfer the delegated NFT
-   Only the current NFT owner can set the delegate address
-   There can only ever be one delegate at a time for an NFT

<br/>

## Potential Use Cases

---

Ideally this registry is simple and flexiable enough that many differenty types of fuctionality could be built on top.

Early potential use cases include:

-   Proving Ownership of Custodial/Cold Storage NFTs
-   NFT Renting
-   Event Check In

<br/>

### Proving Ownership of Custodial NFTs

As the value of NFTs increases over time, many owners will look towards different solutions to custody their expensive NFTs. However, now that the assets are being held by a third party it makes it much more difficult to verify who owns what. You are no longer able to sign an offchain message proving you own an asset if it is being held in a custodial address.

Problem:

Your rare NFT has skyrocketed to over $50k and you don't feel comfortible self custodying anymore. You then pay a custodian and they take custody of the asset. A few weeks later you learn that there is an NFT that is airdropped to all the holders of the NFT you locked in custody. As a result, you are unable to claim your airdropped NFT in time since the valuable NFT you need is being held in a custodial service or maybe even your own personal cold storage.

Solution:

An owner registers an address that they own as a delegate and then passes the NFT off to the custodian. Now anytime they need to prove ownership of an NFT that is in custody; the service, smart contract, or middleware that is validating ownership checks if the offchain signature or onchain transaction came from the delegate address and allows them to claim the airdropped NFT.

<br/>

### NFT Renting

The utility of NFTs will increase over time and certain owners will want to rent out their NFTs to parties that are willing to pay to access said utility, but can't afford to purchase the NFT outright. However, renting out an NFT could be dangerous because if you transfer the NFT to the renter then you are trusting them not to sell it at a profit on the market since the market price will be higher than the rental price. Therefore, it is nessary to be able to create an air gap between the renter being able to access the utility of an NFT and the ability to restrict the renter from the transfer functionallity.

Problem:

You own a game NFT that is for a plot of land which has a lot of mineral deposits. You strike up a deal to rent out the mining rights of this land for 10 ETH per month. You find a renter, get your 10 ETH up front, and then transfer the NFT to the renter so that they can start mining. However, because the land is worth 1000 ETH they immediately run off with the NFT since they have full control.

Solution:

An NFT rental contract is built on top of the delegate registry and the game software that is validating ownership checks if the offchain signature or onchain transaction came from a valid delegate address. In this scenero the renter was able to access the utility of the land NFT, but was never given access to transfer the NFT.

<br/>

### Event Check In

Token gated events are growing in popularity over the last few months. These events sometime require that an owner sign a message at the door to prove they own the correct NFT in order to get in. However, the issue is that the user needs to have their expensive NFTs in a mobile wallet with them when they go to the event. This creates unnessary risk and might not be possible if the NFT is being held by a custodian.

Problem:
You are going to large event in a major city. The event requires that you have your $50k NFT on your phone when you check into the event in order to get in. Transferring your valuable NFT to a mobile device to store is and then walk around with in a major city is less than ideal from a safety standpoint.

Solution:
Register an empty address in your mobile wallet as a delegate. Then when you arrive at the event you can produce a signature from the your empty mobile wallet and the event can check if that address is a delegate to a valid NFT. This method safer since you don't need to carry around expensive NFTs on your person or you don't need to get the NFT from a custodian if you set up a delegate address before you handed over the NFT to them.

<br/>

## Contract Interface

---

### getDelegate

Returns the delegate address for a given ERC-721 NFT.

```
function getDelegate(address _tokenAddress, uint _tokenId)
```

<br/>

### setDelegate

Sets the delegate address for a given ERC-721 NFT.

```
function setDelegate(
    address _tokenAddress,
    uint _tokenId,
    address _delegateAddress
)
```

<br/>

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

<br/>

### DelegateSet Event

Emitted whenever a new delegate address is set.

```
event DelegateSet(address tokenAddress, uint tokenId, address owner, address delegateAddress);
```
