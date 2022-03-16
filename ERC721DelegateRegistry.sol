// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

import "@openzeppelin/contracts/cryptography/ECDSA.sol";

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

/// @title ERC-721 Delegate Registry
/// @notice Allows an NFT owner to register another address to be a delegate on its behalf without giving over control of the NFT
contract ERC721DelegateRegistry {
    using ECDSA for bytes32;

    /// @notice EIP-712 Domain Separtor
    bytes32 private constant DOMAIN_SALT = 0xaee422d4a3edcb9b2222d503bfe733db1e3f6cdc2b7971ee739626c97e86a449;
    string private constant EIP712_DOMAIN = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 DOMAIN_SALT)";
    bytes32 private constant EIP712_DOMAIN_TYPEHASH = keccak256(abi.encodePacked(EIP712_DOMAIN));
    bytes32 DOMAIN_SEPARATOR = keccak256(abi.encode(
        EIP712_DOMAIN_TYPEHASH,
        keccak256("ERC-721 Delegate Registry"),
        keccak256("1.0"), // Version
        keccak256("1"), // ChainId - ETH Mainnet
        address(this),
        DOMAIN_SALT
    ));
    string private constant DELEGATE_TYPE = "Delegate(address tokenAddress,uint tokenId,address delegateAddress)";
    bytes32 private constant DELEGATE_TYPEHASH = keccak256(abi.encodePacked(DELEGATE_TYPE));

    struct Delegate {
        address tokenAddress;
        uint tokenId;
        address delegateAddress;
    }

    /// @notice Returns a delegate for a speific NFT, if one exists
    /// @dev ERC-721 Contract Address => ERC-721 Token ID => Delegate Address
    mapping(address => mapping(uint => address)) private tokenDelegateRegistry;

    /// @notice Emitted whenever a new delegate address is set
    /// @param tokenAddress - ERC-721 Contract Address
    /// @param tokenId - ERC-721 Token ID
    /// @param owner - Current NFT Owner
    /// @param delegateAddress - New Delegate Address
    event DelegateSet(address tokenAddress, uint tokenId, address owner, address delegateAddress);

    /// @notice Returns the delegate address for a given ERC-721 NFT
    /// @param _tokenAddress - ERC-721 Token Contract Address
    /// @param _tokenId - ERC-721 Token ID
    function getDelegate(address _tokenAddress, uint _tokenId) public view returns(address) {
        return tokenDelegateRegistry[_tokenAddress][_tokenId];
    }


    /// @notice Sets the delegate address for a given ERC-721 NFT
    /// @param _tokenAddress - ERC-721 Token Contract Address
    /// @param _tokenId - ERC-721 Token ID
    /// @param _delegateAddress - Address of the new delegate
    function setDelegate(
        address _tokenAddress, 
        uint _tokenId, 
        address _delegateAddress
    ) public {
        address tokenOwner = IERC721(_tokenAddress).ownerOf(_tokenId);
        require(msg.sender == tokenOwner); 
        tokenDelegateRegistry[_tokenAddress][_tokenId] = _delegateAddress;

        emit DelegateSet(_tokenAddress, _tokenId, msg.sender, _delegateAddress);
    }

    /// @notice Sets the delegate address for a given ERC-721 NFT with a signature from the owner
    /// @param _tokenAddress - ERC-721 Token Contract Address
    /// @param _tokenId - ERC-721 Token ID
    /// @param _delegateAddress - Address of the new delegate
    /// @param _signature - Cryptographic signature signed by the token owner
    function setDelegateWithSig(
        address _tokenAddress, 
        uint _tokenId, 
        address _delegateAddress,
        bytes memory _signature
    ) public {
        Delegate memory delegate = Delegate({
            tokenAddress: _tokenAddress,
            tokenId: _tokenId,
            delegateAddress: _delegateAddress
        });

        bytes32 hash = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            keccak256(abi.encode(
                DELEGATE_TYPEHASH,
                delegate.tokenAddress,
                delegate.tokenId,
                delegate.delegateAddress
            ))
        ));

        address tokenOwner = IERC721(_tokenAddress).ownerOf(_tokenId);
        require(tokenOwner == hash.recover(_signature));
        tokenDelegateRegistry[_tokenAddress][_tokenId] = _delegateAddress;

        emit DelegateSet(_tokenAddress, _tokenId, tokenOwner, _delegateAddress);
    }
}