import { Contract, Signer } from "ethers";
import { ethers } from "hardhat";
import "@nomiclabs/hardhat-ethers";

async function main() {
    const signers: Signer[] = await ethers.getSigners()
    let tokenInstance: Contract;

    const DogEatDogWorldNFT = await ethers.getContractFactory("DogEatDogWorldNFT", signers[1]);
    const dogEatDogWorldNFT = await DogEatDogWorldNFT.deploy();

    console.log("dogEatDogWorldNFT Address", dogEatDogWorldNFT.address);


}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.log(error);
        process.exit(1);
    })