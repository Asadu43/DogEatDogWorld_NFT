// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "erc721a-upgradeable/contracts/ERC721AUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";

contract DogEatDogWorldNFT is
    ERC721AUpgradeable
{
     using SafeMathUpgradeable for uint256;

    uint256 public startingTime;
    address public owner;
    uint256 public constant MAX_SUPPLY = 40;
    uint256 public constant WL_MAX_LIMIT = 3;
    uint256 public constant MAX_LIMIT = 10;
    uint256 public constant MINT_FEE_WL = 0.006 ether;
    uint256 public constant MINT_FEE = 0.009 ether;


    // Base URL string
    string private baseURL;

    //Merkel tree root for whitelisting addresses
    bytes32 private merkleRoot;

    mapping(address => uint256) public ogListed;

    enum PhasesEnum {
        WHITELIST,
        PUBLIC
    }

    PhasesEnum currentPhase;


    function initialize() initializerERC721A  public {
        __ERC721A_init("Dog Eat Dog World", "DEDW");
        owner = msg.sender;
        currentPhase =  PhasesEnum.WHITELIST;
    }

     // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /**
     * @dev Returns the token URL of the NFT .
     */
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        // if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        return
            bytes(baseURL).length > 0
                ? string(abi.encodePacked(baseURL, tokenId))
                : "";
    }

    /**
     * @dev Set the base URL of the NFT .
     * Can only be called by owner.
     */
    function setbaseURI(string memory _uri) external onlyOwner {
        baseURL = _uri;
    }

    function startMinting() external onlyOwner {
        startingTime = block.timestamp;
    }

    /**
     * @dev Sets merkelRoot varriable.
     * Only owner can call it.
     */
    function setMerkelRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function getMerkelRoot() external view returns (bytes32) {
        return merkleRoot;
    }

        
    function safeMint(
        bytes32[] calldata _merkleProof,
        uint256 quantity) public payable {
        require(startingTime != 0, "Minting is Not Allowed");
        require(totalSupply().add(quantity) <= MAX_SUPPLY, "MAX Supply Reached");

        if (
            currentPhase == PhasesEnum.WHITELIST &&
            block.timestamp >= startingTime + 2 hours
        ) {
            currentPhase =  PhasesEnum.PUBLIC;
        }

        if (currentPhase == PhasesEnum.WHITELIST) {
            require(msg.value == MINT_FEE_WL, "Not Enough Ethers");
                require(
                    MerkleProofUpgradeable.verify(
                        _merkleProof,
                        merkleRoot,
                        keccak256(abi.encodePacked(msg.sender))
                    ),
                    "User Not Whitelisted"
                );
                require((ogListed[msg.sender] + quantity)  <=  WL_MAX_LIMIT , "Can't mint more than 3");
                ogListed[msg.sender] = (ogListed[msg.sender] + quantity);
                _mint(msg.sender, quantity);
             
        }else if(currentPhase ==  PhasesEnum.PUBLIC){
        require(msg.value == MINT_FEE, "Not Enough Ethers");
        require(quantity <= MAX_LIMIT, "You can't mint more than 10");
        _mint(msg.sender, quantity);
        } 
    }
}
