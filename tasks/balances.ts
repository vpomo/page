// import "@nomiclabs/hardhat-web3";
import "@nomiclabs/hardhat-ethers";
import { task } from "hardhat/config";

task("balance", "Prints an account's balance")
    .addParam("account", "The account's address")
    .setAction(async (taskArgs, { ethers }) => {
        const account = ethers.utils.getAddress(taskArgs.account);
        const balance = await ethers.provider.getBalance(account);
        console.log(ethers.utils.parseUnits(String(balance), 18), "ETH");
    });

export default {
    solidity: "0.8.4",
};
