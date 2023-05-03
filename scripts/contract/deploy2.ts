import { Contract, Signer } from "ethers";
import { ethers, upgrades } from "hardhat";
import "@nomiclabs/hardhat-ethers";

async function main() {
    const signers: Signer[] = await ethers.getSigners()
    const DogEatDogWorldNFT = await ethers.getContractFactory("DogEatDogWorldNFT", signers[1]);
    const dogEatDogWorldNFT = await upgrades.upgradeProxy("0x775b4B86CD4cf8001fCAfDC79638a97917e255fa", DogEatDogWorldNFT); // PROXY_CONTRACT_ADDRESS==> 0x775b4B86CD4cf8001fCAfDC79638a97917e255fa
    await dogEatDogWorldNFT.deployed();
    console.log("Box deployed to:", dogEatDogWorldNFT.address);


}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.log(error);
        process.exit(1);
    })