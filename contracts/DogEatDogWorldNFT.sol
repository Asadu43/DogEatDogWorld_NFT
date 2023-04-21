// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "erc721a-upgradeable/contracts/ERC721AUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";

contract DogEatDogWorldNFT is ERC721AUpgradeable {
    using SafeMathUpgradeable for uint256;

    uint256 public startingTime;
    address public owner;
    uint256 public constant MAX_SUPPLY = 4444;
    uint256 public constant WL_MAX_LIMIT = 3;
    uint256 public constant MAX_LIMIT = 10;
    uint256 public constant MINT_FEE_WL = 0.006 ether;
    uint256 public constant MINT_FEE = 0.009 ether;

    // Base URL string
    string private baseURL;

    //Merkel tree root for whitelisting addresses
    bytes32 private merkleRoot;

    mapping(address => uint256) public ogListed;

    bool public isRevealed;

    enum PhasesEnum {
        WHITELIST,
        PUBLIC
    }

    PhasesEnum currentPhase;


    error MAX_SUPPLY_REACHED();
    error NOT_MINT_0_NFT();
    error MINTING_IS_NOT_ALLOWED();
    error INSUFFICIENT_FUNDS();
    error USER_NOT_WHITELISTED();
    error NOT_MINT_MORE_THAN_3();
    error NOT_MINT_MORE_THAN_10();


    function initialize() public initializerERC721A {
        __ERC721A_init("Dog Eat Dog World", "DEDW");
        owner = msg.sender;
        isRevealed = false;
        currentPhase = PhasesEnum.WHITELIST;
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
        if (isRevealed) {
            return
                bytes(baseURL).length > 0
                    ? string(abi.encodePacked(baseURL, tokenId))
                    : "";
        } else {
            return
                bytes(baseURL).length > 0
                    ? string(abi.encodePacked(baseURL, "unRevealed.json"))
                    : "";
        }
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

    function updateTime(uint256 _time) external onlyOwner {
        startingTime = _time;
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
        uint256 quantity
    ) public payable {
        if(quantity == 0) revert NOT_MINT_0_NFT();
        if(startingTime == 0 ) revert MINTING_IS_NOT_ALLOWED();
        if(totalSupply().add(quantity) > MAX_SUPPLY) revert MAX_SUPPLY_REACHED();

        if (
            currentPhase == PhasesEnum.WHITELIST &&
            block.timestamp >= startingTime + 2 hours
        ) {
            currentPhase = PhasesEnum.PUBLIC;
        }

        if (currentPhase == PhasesEnum.WHITELIST) {
            if(msg.value != MINT_FEE_WL.mul(quantity)) revert INSUFFICIENT_FUNDS();
            if(MerkleProofUpgradeable.verify(
                    _merkleProof,
                    merkleRoot,
                    keccak256(abi.encodePacked(msg.sender))
                ) == false
            ) revert USER_NOT_WHITELISTED();
            if(
                (ogListed[msg.sender] + quantity) > WL_MAX_LIMIT
            ) revert NOT_MINT_MORE_THAN_3();
            ogListed[msg.sender] = (ogListed[msg.sender] + quantity);
            _mint(msg.sender, quantity);
        } else if (currentPhase == PhasesEnum.PUBLIC) {
            if(msg.value != MINT_FEE.mul(quantity))  revert INSUFFICIENT_FUNDS();
            if(quantity > MAX_LIMIT) revert NOT_MINT_MORE_THAN_10();
            _mint(msg.sender, quantity);
        }
    }

    // Withdraw ether balance to owner
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
    }

    function getPrice() external view returns (uint256) {
        if (currentPhase == PhasesEnum.WHITELIST) {
            return MINT_FEE_WL;
        } else if (currentPhase == PhasesEnum.PUBLIC) {
            return MINT_FEE;
        } else {
            return 0;
        }
    }

    function reveal(bool _isRevealed) external onlyOwner {
        isRevealed = _isRevealed;
    }
}
