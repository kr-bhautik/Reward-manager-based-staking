import { ethers } from "hardhat";

const contractAddress = '0xb383aaFA7A3AF7404644c372197AAd8BB4Ad7e32';
async function main() {
    const StakingContract = await ethers.getContractFactory('RewardManagerStaking');
    console.log("Deploying staking contract...")
    const tx = await StakingContract.deploy(contractAddress);
    console.log("Contract deployed at", await tx.getAddress());
}
main().then(() => console.log("Success")).catch((err) => console.log(err));