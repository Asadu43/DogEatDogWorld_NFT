// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "hardhat/console.sol";

contract DogEatDogWorldNFT is ERC721, Ownable {
    uint256 public deploymentTime;
    uint256 mainPhaseCounter = 0;

    // Base URL string
    string private baseURL;

    //Merkel tree root for whitelisting addresses
    bytes32 private merkleRoot;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    mapping(address => bool) public ogListed;

    enum PhasesEnum {
        OG,
        WHITELIST,
        MAIN,
        PUBLIC
    }

    struct Phase {
        uint256 totalMint;
        PhasesEnum phase;
    }

    Phase public currentPhase;

    constructor() ERC721("Dog Eat Dog World", "DEDW") {
        deploymentTime = block.timestamp;
        currentPhase = Phase({totalMint: 777, phase: PhasesEnum.OG});
    }

    /**
     * @dev Returns the base URL of the NFT .
     */
    function _baseURI() internal view override returns (string memory) {
        return baseURL;
    }

    /**
     * @dev Set the base URL of the NFT .
     * Can only be called by owner.
     */
    function setbaseURI(string memory _uri) external onlyOwner {
        baseURL = _uri;
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
        require(msg.value == 0.04 ether, "Not Enough Ethers");
        uint256 tokenId = _tokenIdCounter.current();
        /*        
        if (block.timestamp <= deploymentTime + 24 hours) { //> NO Mint Phase 

            if (block.timestamp > deploymentTime + 6 hours) {
                currentPhase.phase = PhasesEnum.OG;
            }
        }
        

        if (currentPhase.phase == PhasesEnum.WHITELIST) {
            require(tokenId < currentPhase.totalMint, "Out of Stock");
            require(MerkleProof.verify(_merkleProof,merkleRoot,keccak256(abi.encodePacked(msg.sender))),"User Not Whitelisted");
            require(ogListed[msg.sender] == false, "Already Minted NFT");
            _tokenIdCounter.increment();
            ogListed[msg.sender] = true;
            _safeMint(msg.sender, tokenId);
        } 
    */
        if (
            currentPhase.phase == PhasesEnum.OG &&
            block.timestamp >= (deploymentTime + 8 days)
        ) {
            currentPhase.phase = PhasesEnum.MAIN;
            currentPhase.totalMint = 7000 + (777 - tokenId);
        }

        if (currentPhase.phase == PhasesEnum.OG) {
            require(
                block.timestamp <= deploymentTime + 24 hours,
                "OG Mint phase is over"
            );
            require(ogListed[msg.sender] == false, "Already Minted NFT");
            require(tokenId < currentPhase.totalMint, "Out of Stock");

            if (block.timestamp <= deploymentTime + 6 hours) {
                require(
                    MerkleProof.verify(
                        _merkleProof,
                        merkleRoot,
                        keccak256(abi.encodePacked(msg.sender))
                    ),
                    "User Not Whitelisted"
                );
                _tokenIdCounter.increment();
                ogListed[msg.sender] = true;
                _safeMint(msg.sender, tokenId);
                console.log(tokenId);
            } else {
                _tokenIdCounter.increment();
                ogListed[msg.sender] = true;
                _safeMint(msg.sender, tokenId);
            }
        } else if (currentPhase.phase == PhasesEnum.MAIN) {
            require(mainPhaseCounter < currentPhase.totalMint, "Out of Stock");
            if (block.timestamp <= (deploymentTime + 8 days + 2 hours)) {
                //TODO Check for whitelist
                require(
                    MerkleProof.verify(
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
            block.timestamp > (deploymentTime + 8 days),
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
