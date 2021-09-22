async function connect() {
  const _PageAdmin = await ethers.getContractFactory("PageAdmin");
  let x = await _PageAdmin.connect('0x3ca1ce8accde7f0d69D02dda71AdB44C42206557').PAGE_MINTER;
  console.log(x);
}

async function test_init() {
  /*
  PageAdmin is deploying...
  PageAdmin deployed to: 0xfF76b99A8e216119BC887C8C73f1081eba647B2F
  PageToken is deploying...
  PageToken deployed to: 0x45eB06bc12c0A9A9969Fabf1e0BCff5C90f7e232
  PageMinterNFT is deploying...
  PageMinterNFT deployed to: 0x63975e56E60c91E38e3FBd51A6A75a75d1Bd724E
  */
}


/*
PageAdmin deployed to: 0x075C26D0C6f7319F27De106dBB1e7083d7455B3E
PageToken is deploying...
PageToken deployed to: 0xd77E8d7e77AeBc8cDaa6CD746F12AD59807919d9
PageMinterNFT is deploying...
PageMinterNFT deployed to: 0xca4fea34d29807531EF8aC7146C6B92fC42846A8
*/

const saveContracts = async (contracts) => {
  console.log(contracts)
  const fs = require('fs')
  let fileName = './contracts.json'
  fs.writeFileSync(fileName, JSON.stringify(contracts));
}

async function main() {
  
  await saveContracts({
    PAGE_ADMIN: '0xe40Fad1Fa0803e5FBeE92d5e4C0804A70B381F2B',
    PAGE_TOKEN: '0x50e5e0609FF5e1b130BEe29aDAa97c57C49D9504',
    PAGE_NFT: '0x86e7cb5faCD6d70bc7e396314221274170F2d709',
    PAGE_MINTER: '0x3A4EBED9072931c097907BD367C22FD432FCE1D8'
  });

  console.log('FINALE');

  // => file create

  // We get the contract to deploy

  /*
    const PageAdmin = await _PageAdmin.deploy();
    console.log("PageAdmin deployed to:", PageAdmin.address);
  */

  // PAGE ADMIN
  // 0x3ca1ce8accde7f0d69D02dda71AdB44C42206557

  // console.log("Account balance:", (await deployer.getBalance()).toString());  

  /*****
    const _PageNFT = await ethers.getContractFactory("PageMinterNFT");
    const PageNFT = await _PageNFT.deploy();

    await PageAdmin.connect(PageAdmin.address).init(PageNFT.address);

    const CryptoPageToken = await ethers.getContractFactory("PageToken");
    const PageToken = await CryptoPageToken.deploy();
    console.log("Greeter deployed to:", PageToken.address);
  */

  // MINT NFT
  // MINT ADMIN
  // const Greeter = await ethers.getContractFactory("PageMinterNFT");
  // this is constructоr .. await Greeter.deploy("Hello, Hardhat!");
  //await greeter.connect(addr1).setGreeting("Hallo, Erde!");
}
  

main()
.then(() => process.exit(0))
.catch((error) => {
  console.error(error);
  process.exit(1);
});