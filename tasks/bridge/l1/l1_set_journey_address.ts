
import "@nomiclabs/hardhat-ethers";
import { Provider, defaultProvider, stark } from 'starknet'
import {ethers as hardhatEthers, network} from "hardhat"
import * as ethers from "ethers"
import dotenv from "dotenv"
dotenv.config()

async function main() {

  const lockboxFactory = await hardhatEthers.getContractFactory("RealmsL1Bridge");

  const lockbox = await lockboxFactory.attach((process.env as any)[`L1_REALMS_BRIDGE_LOCKBOX_${network.name.toUpperCase()}`])

  const res = await lockbox.setJourneyV1Address((process.env as any)[`L1_JOURNEY_ADDRESS_${network.name.toUpperCase()}`])
  const res2 = await lockbox.setJourneyV2Address((process.env as any)[`L1_CARRACK_ADDRESS_${network.name.toUpperCase()}`])

  console.log(res)
  console.log(res2)
}

main();