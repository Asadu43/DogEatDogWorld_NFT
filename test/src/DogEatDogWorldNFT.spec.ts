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

  });


  it.only("MerkleTree Creationn And Set Markle Tree Root", async function () {
  
    whiteListedAddresses = [owner, user1, user3, user5];

    const leafNodes = whiteListedAddresses.map((x: SignerWithAddress) => keccak256(x.address));
    mtree = new MerkleTree(leafNodes, keccak256, { sort: true });
    root = mtree.getHexRoot()
    const leaf = keccak256(user1.address)
    const proof = mtree.getHexProof(leaf)

    await dogEatDogWorldNFT.connect(owner).setMerkelRoot(root)



  })

  it.only("Minting is Not Allowed", async function () {
  
    for (let i = 0; i < whiteListedAddresses.length; i++) {
      const leaf = keccak256(whiteListedAddresses[i].address)
      const proof = mtree.getHexProof(leaf)
      await expect(dogEatDogWorldNFT.connect(whiteListedAddresses[i]).safeMint(proof,2,{value:parseEther("0.005")})).to.be.revertedWith("Minting is Not Allowed");
    }
  })

  it.only("Start minting", async function () {
    await dogEatDogWorldNFT.connect(owner).startMinting();
  
  })


  it.only("Not Enough Ethers", async function () {
  
    for (let i = 0; i < whiteListedAddresses.length; i++) {
      const leaf = keccak256(whiteListedAddresses[i].address)
      const proof = mtree.getHexProof(leaf)
      await expect(dogEatDogWorldNFT.connect(whiteListedAddresses[i]).safeMint(proof,2,{value:parseEther("0.005")})).to.be.revertedWith("Not Enough Ethers");
    }
  })

  it.only("User Not Whitelisted", async function () {
  
    for (let i = 0; i < whiteListedAddresses.length; i++) {
      const leaf = keccak256(whiteListedAddresses[i].address)
      const proof = mtree.getHexProof(leaf)
      await expect(dogEatDogWorldNFT.connect(whiteListedAddresses[i]).safeMint([],2,{value:parseEther("0.012")})).to.be.revertedWith("User Not Whitelisted");
    }
  })

  it.only("Can't mint more than 3", async function () {
  
    for (let i = 0; i < whiteListedAddresses.length; i++) {
      const leaf = keccak256(whiteListedAddresses[i].address)
      const proof = mtree.getHexProof(leaf)
      await expect(dogEatDogWorldNFT.connect(whiteListedAddresses[i]).safeMint(proof,4,{value:parseEther("0.024")})).to.be.revertedWith("Can't mint more than 3");
    }
  })


  it.only("MINT NFT", async function () {
  
    for (let i = 0; i < whiteListedAddresses.length; i++) {
      const leaf = keccak256(whiteListedAddresses[i].address)
      const proof = mtree.getHexProof(leaf)
      await dogEatDogWorldNFT.connect(whiteListedAddresses[i]).safeMint(proof,2,{value:parseEther("0.012")});
    }
  })


  it.only("Not Enough Ethers", async function () {
  
    for (let i = 0; i < whiteListedAddresses.length; i++) {
      const leaf = keccak256(whiteListedAddresses[i].address)
      const proof = mtree.getHexProof(leaf)
      await expect(dogEatDogWorldNFT.connect(whiteListedAddresses[i]).safeMint(proof,2,{value:parseEther("0.012")})).to.be.revertedWith("Can't mint more than 3");
    }
  })

  it.only("MINT NFT", async function () {
  
    for (let i = 0; i < whiteListedAddresses.length; i++) {
      const leaf = keccak256(whiteListedAddresses[i].address)
      const proof = mtree.getHexProof(leaf)
      await dogEatDogWorldNFT.connect(whiteListedAddresses[i]).safeMint(proof,1,{value:parseEther("0.006")});
    }
  })


  it.only("Increase Time", async function () {
  increaseTime(21600);

})

it.only("MINT NFT in Public Phase", async function () {

  await dogEatDogWorldNFT.connect(user2).safeMint([],10,{value:parseEther("0.09")});
  
})

it.only("You can't mint more than 10", async function () {

  await expect(dogEatDogWorldNFT.connect(user2).safeMint([],11,{value:parseEther("0.099")})).to.be.revertedWith("You can't mint more than 10");
  
})

it.skip("Not Enough Ethers", async function () {

  await expect(dogEatDogWorldNFT.connect(user2).safeMint([],11,{value:parseEther("0.099")})).to.be.revertedWith("Not Enough Ethers");
  
})

it.only("MINT NFT in Public Phase", async function () {

  await dogEatDogWorldNFT.connect(user4).safeMint([],10,{value:parseEther("0.09")});
  
})


it.only("MINT NFT in Public Phase", async function () {

  await expect(dogEatDogWorldNFT.connect(user5).safeMint([],10,{value:parseEther("0.09")})).to.be.revertedWith("MAX Supply Reached");
  
})

it.only("MINT NFT in Public Phase", async function () {

  await dogEatDogWorldNFT.connect(user4).safeMint([],8,{value:parseEther("0.072")});
  
})

});
