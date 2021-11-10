const fs = require("fs");

const saveContracts = async (contracts) => {
    // console.log(contracts);
    let fileName = "./contracts.json";
    fs.writeFileSync(fileName, JSON.stringify(contracts));
};

async function deploy(ContractName, construct) {
    const _Contract = await ethers.getContractFactory(ContractName);
    // DEPLOYING

    const Contract = await _Contract.deploy(construct);
    // console.log(`${ContractName} is deploying...`);
    // AWAIT FOR DEPLOYED
    await Contract.deployed();
    // console.log(`${ContractName} deployed to:`, Contract.address);
    return Contract;
}

async function main() {
    // STEP 1
    let PageProfile = await deploy(
        "PageProfile",
        "0xcE65382a0a49C8b3Cf3C1C446d15DBAA14FCAb86"
    );
    let PAGE_PROFILE = PageProfile.address;
    // console.log("|- PAGE_PROFILE = ", PAGE_PROFILE);
    await saveContracts({
        PAGE_PROFILE: PAGE_PROFILE,
    });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        // console.error(error);
        process.exit(1);
    });
