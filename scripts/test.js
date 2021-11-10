const fs = require("fs");

const saveContracts = async (contracts) => {
    console.log("contracts:", contracts);
    let fileName = "./contracts.json";
    fs.writeFileSync(fileName, JSON.stringify(contracts));
};

async function main() {
    await saveContracts({
        PAGE_ADMIN: "0xe40Fad1Fa0803e5FBeE92d5e4C0804A70B381F2B",
        PAGE_TOKEN: "0x50e5e0609FF5e1b130BEe29aDAa97c57C49D9504",
        PAGE_NFT: "0x86e7cb5faCD6d70bc7e396314221274170F2d709",
        PAGE_MINTER: "0x3A4EBED9072931c097907BD367C22FD432FCE1D8",
    });
    console.log("Contracts was saved");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
