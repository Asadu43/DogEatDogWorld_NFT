import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { Contract, BigNumber, Signer } from "ethers";
import { keccak256, parseEther } from "ethers/lib/utils";
import hre, { ethers, upgrades } from "hardhat";
import MerkleTree from "merkletreejs/dist/MerkleTree";
import { increaseTime } from "../utils/utilities";



const bufToHex = (x: any) => '0x' + x.toString('hex')

describe("DogEatDogWorldNFT Token", function () {

  let signers: Signer[];

  let owner: SignerWithAddress;
  let user1: SignerWithAddress;
  let user2: SignerWithAddress;
  let user3: SignerWithAddress;

  let user4: SignerWithAddress;
  let user5: SignerWithAddress;
  let user6: SignerWithAddress;


  let dogEatDogWorldNFT: Contract;
  let mtree: MerkleTree;
  let root: string;

  let whiteListedAddresses: SignerWithAddress[];

  before(async () => {
    [owner, user1, user2, user3, user4, user5, user6] = await ethers.getSigners();


    const DogEatDogWorldNFT = await ethers.getContractFactory("DogEatDogWorldNFT", owner);
    dogEatDogWorldNFT = await upgrades.deployProxy(DogEatDogWorldNFT);
    await dogEatDogWorldNFT.deployed();
    console.log("Box deployed to:", dogEatDogWorldNFT.address);

  });

  it.only("Base URL", async function(){
    await dogEatDogWorldNFT.setbaseURI("this_base.url/token/");
    const tokenURI = await dogEatDogWorldNFT.tokenURI(999);
    console.log(tokenURI);
    
  })

  it("MerkleTree Creationn And Set Markle Tree Root", async function () {
    console.log(owner.address);
    console.log("Box deployed to:", dogEatDogWorldNFT.address);


    whiteListedAddresses = [owner, user1, user3, user5];

    const leafNodes = whiteListedAddresses.map((x: SignerWithAddress) => keccak256(x.address));
    mtree = new MerkleTree(leafNodes, keccak256, { sort: true });
    root = mtree.getHexRoot()

    console.log(mtree.toString());
    console.log('root ', root);
    const leaf = keccak256(user1.address)
    const proof = mtree.getHexProof(leaf)
    console.log(bufToHex(proof));

    await dogEatDogWorldNFT.connect(owner).setMerkelRoot(root)

    await dogEatDogWorldNFT.connect(owner).startMinting()

  })


  it("User Not WhiteListed", async function () {
    await expect(dogEatDogWorldNFT.connect(user2).safeMint([], { value: parseEther("0.04") })).to.be.revertedWith("User Not Whitelisted")
  })

  it("Not Enough Ethers", async function () {
    await expect(dogEatDogWorldNFT.connect(user2).safeMint([], { value: parseEther("0.03") })).to.be.revertedWith("Not Enough Ethers")
  })

  it("User WhiteListed", async function () {

    console.log(mtree.toString());
    console.log('root ', root);
    const leaf = keccak256(user1.address)
    const proof = mtree.getHexProof(leaf)
    console.log(bufToHex(proof));

    const leaf2 = keccak256(user3.address)
    const proof2 = mtree.getHexProof(leaf2)
    console.log(bufToHex(proof2));
    await dogEatDogWorldNFT.connect(user1).safeMint(proof, { value: parseEther("0.04") })
    await dogEatDogWorldNFT.connect(user3).safeMint(proof2, { value: parseEther("0.04") })
    increaseTime(21600);
  })

  it("Already Minted NFT", async function () {
    const leaf2 = keccak256(user3.address)
    const proof2 = mtree.getHexProof(leaf2)
    await expect(dogEatDogWorldNFT.connect(user1).safeMint(proof2, { value: parseEther("0.04") })).to.be.revertedWith("Already Minted NFT")
  })

  it("Any One Can Mint", async function () {
    await dogEatDogWorldNFT.connect(user2).safeMint([], { value: parseEther("0.04") })
  })

  it("Already Minted NFT", async function () {
    await expect(dogEatDogWorldNFT.connect(user2).safeMint([], { value: parseEther("0.04") })).to.be.revertedWith("Already Minted NFT")

  })

  it("Out of Stock", async function () {
    await expect(dogEatDogWorldNFT.connect(user4).safeMint([], { value: parseEther("0.04") })).to.be.revertedWith("Out of Stock");
    increaseTime(669500);
  })

  it("You can't mint in this week", async function () {

    await expect(dogEatDogWorldNFT.connect(user1).freeMint(0)).to.be.revertedWith("You can't mint in this week")

  })

  it("You can't mint in this week", async function () {
    await expect(dogEatDogWorldNFT.connect(user4).safeMint([], { value: parseEther("0.04") })).to.be.revertedWith("OG Mint phase is over");
    increaseTime(100);
  })

  it("Next Phase (MAIN MINT) : User WhiteListed", async function () {

    console.log(mtree.toString());
    console.log('root ', root);
    const leaf = keccak256(user1.address)
    const proof = mtree.getHexProof(leaf)
    console.log(bufToHex(proof));

    const leaf2 = keccak256(user3.address)
    const proof2 = mtree.getHexProof(leaf2)

    console.log(bufToHex(proof2));

    await dogEatDogWorldNFT.connect(user1).safeMint(proof, { value: parseEther("0.04") })
    await dogEatDogWorldNFT.connect(user3).safeMint(proof2, { value: parseEther("0.04") })

  });

  it("User Not Whitelisted", async function () {
    await expect(dogEatDogWorldNFT.connect(user2).safeMint([], { value: parseEther("0.04") })).to.be.revertedWith("User Not Whitelisted")
    increaseTime(7200);

  })

  it("Free Mint", async function () {

    await expect(dogEatDogWorldNFT.connect(user1).freeMint(2)).to.be.revertedWith("You haven't any NFT");

  })

  it("Free Mint", async function () {

    await dogEatDogWorldNFT.connect(user1).freeMint(0)

  })

  it("Any One Can Mint", async function () {
    await dogEatDogWorldNFT.connect(user2).safeMint([], { value: parseEther("0.04") })
  })

  it("Free Mint", async function () {

    await expect(dogEatDogWorldNFT.connect(user1).freeMint(0)).to.be.revertedWith("Not applicable for free mint.")

  })

  it("Free Mint", async function () {

    await expect(dogEatDogWorldNFT.connect(user3).freeMint(1)).to.be.revertedWith("Out of Stock")

  })

  it("Out of Stock", async function () {
    await expect(dogEatDogWorldNFT.connect(user4).safeMint([], { value: parseEther("0.04") })).to.be.revertedWith("Out of Stock");
  })



});
