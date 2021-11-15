const fs = require("fs");

const saveContracts = async (contracts) => {
    console.log(contracts);
    let fileName = "./contracts.json";
    fs.writeFileSync(fileName, JSON.stringify(contracts));
};

async function deploy(ContractName, construct) {
    const _Contract = await ethers.getContractFactory(ContractName);
    // DEPLOYING

    const Contract = await _Contract.deploy(construct);
    console.log(`${ContractName} is deploying...`);
    // AWAIT FOR DEPLOYED
    await Contract.deployed();
    console.log(`${ContractName} deployed to:`, Contract.address);
    return Contract;
}
async function deploy2(ContractName, construct1, construct2) {
    const _Contract = await ethers.getContractFactory(ContractName);
    // DEPLOYING

    const Contract = await _Contract.deploy(construct1, construct2);
    console.log(`${ContractName} is deploying...`);
    // AWAIT FOR DEPLOYED
    await Contract.deployed();
    console.log(`${ContractName} deployed to:`, Contract.address);
    return Contract;
}

async function main() {
    const mnemonic = process.env.MNEMONIC || "";
    const wallet = await ethers.Wallet.fromMnemonic(mnemonic);
    const TreasuryAddress = wallet.address;

    // STEP 1
    let PageAdmin = await deploy("PageAdmin", TreasuryAddress);
    let PAGE_MINTER = await PageAdmin.pageMinter();

    // STEP 1.1
    let PageToken = await deploy("PageToken", PAGE_MINTER);
    let PAGE_TOKEN = PageToken.address;

    // STEP 2
    let PageMinterNFT = await deploy2("PageMinterNFT", PAGE_MINTER, PAGE_TOKEN);
    let PAGE_NFT = PageMinterNFT.address;

    // STEP 3
    await PageAdmin.init(PAGE_NFT, PAGE_TOKEN);

    // console.log("CHANGE OWNER SHIP");
    // await PageAdmin.transferOwnership(
    // "0x73837Fd1188B7200f2c116cf475aC3D71928D26B"
    // );
    console.log("DEPLOYED");

    // LIST OF CONTRACTS:
    console.log("LIST OF CONTRACTS:");

    let PAGE_ADMIN = PageAdmin.address;
    console.log("|- PAGE_ADMIN = ", PAGE_ADMIN);
    console.log("|- PAGE_TOKEN = ", PAGE_TOKEN);
    console.log("|- PAGE_NFT = ", PAGE_NFT);
    console.log("|- PAGE_MINTER = ", PAGE_MINTER);

    await saveContracts({
        PAGE_ADMIN: PAGE_ADMIN,
        PAGE_TOKEN: PAGE_TOKEN,
        PAGE_NFT: PAGE_NFT,
        PAGE_MINTER: PAGE_MINTER,
    });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
