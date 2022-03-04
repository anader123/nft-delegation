pragma solidity 0.8.0;

import "@openzeppelin/contracts/cryptography/ECDSA.sol";

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

/// @title ERC-721 Delegate Registry
/// @notice Allows an NFT owner to register another address to be a delegate on its behalf without having control of the NFT
contract ERC721DelegateRegistry {
    using ECDSA for bytes32;

    /// @notice EIP-712 Domain Separtor
    bytes32 private constant DOMAIN_SALT = 0x444bf2116955b97ef0f55525b1db225c5706e3ds065a400dc9094b10;
    string private constant EIP712_DOMAIN = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)";
    bytes32 private constant EIP712_DOMAIN_TYPEHASH = keccak256(abi.encodePacked(EIP712_DOMAIN));
    bytes32 DOMAIN_SEPARATOR = keccak256(abi.encode(
        EIP712_DOMAIN_TYPEHASH,
        keccak256("ERC-721 Delegate Registry"),
        keccak256("1.0"),
        keccak256("1"),
        address(this),
        salt
    ));
    string private constant DELEGATE_TYPE = "Delegate(address contractAddress,uint tokenId,address delegateAddress)";
    bytes32 private constant DELEGATE_TYPEHASH = keccak256(abi.encodePacked(DELEGATE_TYPE));

    struct Delegate {
        address contractAddress,
        uint tokenId,
        address delegateAddress
    }

    /// @notice Returns a delegate for a speific NFT, if one exists
    /// @dev ERC-721 Contract Address => ERC-721 Token ID => Delegate Address
    mapping(address => mapping(uint => address)) private tokenRegistry;

    /// @notice Emitted whenever a new delegate address is set
    /// @param contractAddress - ERC-721 Contract Address
    /// @param tokenId - ERC-721 Token ID
    /// @param owner - Current NFT Owner
    /// @param delegateAddress - New Delegate Address
    /// @param preDelegateAddress - Previous Delegate Address
    event DelegateSet(address contractAddress, uint tokenId, address owner, address delegateAddress, address prevDelegateAddress);

    /// @notice Returns the delegate address for a given ERC-721 NFT
    /// @param _contractAddress - ERC-721 Contract Address
    /// @param _tokenId - ERC-721 Token ID
    function getDelegate(address _contractAddress, uint _tokenId) public view returns(address) {
        return tokenRegistry[_contractAddress][_tokenId];
    }


    /// @notice Sets the delegate address for a given ERC-721 NFT
    /// @param _contractAddress - ERC-721 Contract Address
    /// @param _tokenId - ERC-721 Token ID
    /// @param _delegateAddress - Address of the new delegate
    function setDelegate(
        address _contractAddress, 
        uint _tokenId, 
        address _delegateAddress
    ) public (_contractAddress, _tokenId) {
        address tokenOwner = IERC721(_contractAddress).ownerOf(_tokenId);
        require(msg.sender == tokenOwner); 

        address prevDelegateAddress = tokenRegistry[_contractAddress][_tokenId];
        tokenRegistry[_contractAddress][_tokenId] = _delegateAddress;

        emit DelegateSet(_contractAddress, _tokenId, msg.sender, _delegateAddress, prevDelegateAddress);
    }

    /// @notice Sets the delegate address for a given ERC-721 NFT with a signature from the owner
    /// @param _contractAddress - ERC-721 Contract Address
    /// @param _tokenId - ERC-721 Token ID
    /// @param _delegateAddress - Address of the new delegate
    /// @param _signature - Cryptographic signature signed by the token owner
    function setDelegateWithSig(
        address _contractAddress, 
        uint _tokenId, 
        address _delegateAddress,
        bytes memory _signature
    ) public (_contractAddress, _tokenId) {
        Delegate memory delegate = Delegate({
            contractAddress: _contractAddress,
            tokenId: _tokenId,
            delegateAddress: _delegateAddress
        });

        bytes32 hash = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            keccak256(abi.encode(
                DELEGATE_TYPEHASH,
                delegate.contractAddress,
                delegate.tokenId,
                delegate.delegateAddress
            ))
        ));

        address tokenOwner = IERC721(_contractAddress).ownerOf(_tokenId);
        require(tokenOwner == hash.recover(_signature));

        address prevDelegateAddress = tokenRegistry[_contractAddress][_tokenId];
        tokenRegistry[_contractAddress][_tokenId] = _delegateAddress;

        emit DelegateSet(_contractAddress, _tokenId, tokenOwner, _delegateAddress, prevDelegateAddress);
    }
}