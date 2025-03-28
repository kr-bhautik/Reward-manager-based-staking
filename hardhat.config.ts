import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from 'dotenv'
dotenv.config()

const localAccount = process.env.LOCAL_KEY || "";
const realAccount = process.env.DEPLOYER_KEY || "";
const config: HardhatUserConfig = {
  solidity: "0.8.28",
  networks: {
    localhost: {
      url: 'https://sepolia.infura.io/v3/716bdb39b2f84516b3cedcfb3c2d2c19',
      chainId: 11155111,
      accounts: [localAccount],
    },
    sepolia: {
      url: 'http://127.0.0.1:7545',
      accounts: [realAccount]
    }
  }
};

export default config;
