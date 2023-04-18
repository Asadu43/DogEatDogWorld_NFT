// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";

contract DogEatDogWorldNFT is
    Initializable,
    ERC721Upgradeable,
    OwnableUpgradeable
{
    using StringsUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter private _tokenIdCounter;

    uint256 public startingTime;
    uint256 mainPhaseCounter;

    // Base URL string
    string private baseURL;

    //Merkel tree root for whitelisting addresses
    bytes32 private merkleRoot;

    mapping(address => bool) public ogListed;

    enum PhasesEnum {
        OG,
        MAIN,
        PUBLIC
    }

    struct Phase {
        uint256 totalMint;
        PhasesEnum phase;
    }

    Phase public currentPhase;

    function initialize() public initializer {
        __ERC721_init("Dog Eat Dog World", "DEDW");
        __Ownable_init();
        currentPhase = Phase({totalMint: 222, phase: PhasesEnum.OG});
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
                ? string(abi.encodePacked(baseURL, tokenId.toString()))
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

    function safeMint(bytes32[] calldata _merkleProof) public payable {
        require(startingTime != 0, "Minting is Not Allowed");
        require(msg.value == 0.04 ether, "Not Enough Ethers");
        uint256 tokenId = _tokenIdCounter.current();
        if (
            currentPhase.phase == PhasesEnum.OG &&
            block.timestamp >= (startingTime + 8 days)
        ) {
            currentPhase.phase = PhasesEnum.MAIN;
            currentPhase.totalMint = 4222 + (222 - tokenId);
        }

        if (currentPhase.phase == PhasesEnum.OG) {
            require(
                block.timestamp <= startingTime + 24 hours,
                "OG Mint phase is over"
            );
            require(ogListed[msg.sender] == false, "Already Minted NFT");
            require(tokenId < currentPhase.totalMint, "Out of Stock");

            if (block.timestamp <= startingTime + 6 hours) {
                require(
                    MerkleProofUpgradeable.verify(
                        _merkleProof,
                        merkleRoot,
                        keccak256(abi.encodePacked(msg.sender))
                    ),
                    "User Not Whitelisted"
                );
                _tokenIdCounter.increment();
                ogListed[msg.sender] = true;
                _safeMint(msg.sender, tokenId);
            } else {
                _tokenIdCounter.increment();
                ogListed[msg.sender] = true;
                _safeMint(msg.sender, tokenId);
            }
        } else if (currentPhase.phase == PhasesEnum.MAIN) {
            require(mainPhaseCounter < currentPhase.totalMint, "Out of Stock");
            if (block.timestamp <= (startingTime + 8 days + 2 hours)) {
                //TODO Check for whitelist
                require(
                    MerkleProofUpgradeable.verify(
                        _merkleProof,
                        merkleRoot,
                        keccak256(abi.encodePacked(msg.sender))
                    ),
                    "User Not Whitelisted"
                );

                mainPhaseCounter++;
                _tokenIdCounter.increment();
                _safeMint(msg.sender, tokenId);
            } else {
                mainPhaseCounter++;
                _tokenIdCounter.increment();
                _safeMint(msg.sender, tokenId);
            }
        }
    }

    function freeMint(uint256 id) public {
        uint256 tokenId = _tokenIdCounter.current();
        require(
            block.timestamp > (startingTime + 8 days),
            "You can't mint in this week"
        );
        require(ogListed[msg.sender] == true, "Not applicable for free mint.");
        require(ownerOf(id) == msg.sender, "You haven't any NFT");
        require(mainPhaseCounter < currentPhase.totalMint, "Out of Stock");
        mainPhaseCounter++;
        ogListed[msg.sender] = false;
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }
}
