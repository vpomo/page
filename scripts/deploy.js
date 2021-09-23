



const saveContracts = async (contracts) => {
  console.log(contracts)
  const fs = require('fs')
  let fileName = './contracts.json'
  fs.writeFileSync(fileName, JSON.stringify(contracts));
}




const verifyContracts = async (contracts, network) => {
  if (
    verifiableNetwork.includes(network)
  ) {
    // tslint:disable-next-line: no-console
    console.log("Beginning Etherscan verification process...\n",
      chalk.yellow(`WARNING: The process will wait two minutes for Etherscan \nto update their backend before commencing, please wait \nand do not stop the terminal process...`)
    );

    const bar = new ProgressBar('Etherscan update: [:bar] :percent :etas', {
      total: 50,
      complete: '\u2588',
      incomplete: '\u2591',
    });
    // two minute timeout to let Etherscan update
    const timer = setInterval(() => {
      bar.tick();
      if (bar.complete) {
        clearInterval(timer)
      }
    }, 2300);

    await pause(120000);

    // there may be some issues with contracts using libraries 
    // if you experience problems, refer to https://hardhat.org/plugins/nomiclabs-hardhat-etherscan.html#providing-libraries-from-a-script-or-task
    // tslint:disable-next-line: no-console
    console.log(chalk.cyan("\n� Running Etherscan verification..."));

    await Promise.all(contracts.map(async contract => {
      // tslint:disable-next-line: no-console
      console.log(`Verifying ${contract.name}...`);
      try {
        // normally, implementation contract has no constructor
        await hre.run("verify:verify", {
          address: contract.implAddress,
          constructorArguments: []
        });
        // tslint:disable-next-line: no-console
        console.log(chalk.cyan(`✅ ${contract.name} verified!`));
      } catch (error) {
        // tslint:disable-next-line: no-console
        console.log(error);
      }
    }));
  }
}


async function deploy(ContractName, construct) {
  const _Contract = await ethers.getContractFactory(ContractName)
  // DEPLOYING

  const Contract = await _Contract.deploy(construct)
  console.log(`${ContractName} is deploying...`)
  // AWAIT FOR DEPLOYED
  await Contract.deployed()
  console.log(`${ContractName} deployed to:`, Contract.address)
  return Contract
}
async function deploy2(ContractName, construct1, construct2) {
  const _Contract = await ethers.getContractFactory(ContractName)
  // DEPLOYING

  const Contract = await _Contract.deploy(construct1, construct2)
  console.log(`${ContractName} is deploying...`)
  // AWAIT FOR DEPLOYED
  await Contract.deployed()
  console.log(`${ContractName} deployed to:`, Contract.address)
  return Contract
}



async function main() {

    let TreasuryAddress = "0x09d6a2224c62ec977bc29e438c3cf0df16d4775a"

    // STEP 1
    let PageAdmin = await deploy('PageAdmin', TreasuryAddress)
    let PAGE_MINTER = await PageAdmin.PAGE_MINTER()

    // STEP 1.1
    let PageToken = await deploy('PageToken', PAGE_MINTER)
    let PAGE_TOKEN = PageToken.address

    // STEP 2
    let PageMinterNFT = await deploy2('PageMinterNFT', PAGE_MINTER, PAGE_TOKEN)
    let PAGE_NFT = PageMinterNFT.address

    // STEP 3
    await PageAdmin.init(PAGE_NFT, PAGE_TOKEN)

    // STEP 4
    /*    
    console.log("setMinter: NFT_CREATE")
    await PageAdmin.setMinter("NFT_CREATE", PAGE_NFT, "1000000000000000000")

    console.log("setMinter: NFT_CREATE_WITH_COMMENT")
    await PageAdmin.setMinter("NFT_CREATE_WITH_COMMENT", PAGE_NFT, "1000000000000000000")

    console.log("setMinter: NFT_CREATE_ADD_COMMENT")
    await PageAdmin.setMinter("NFT_CREATE_ADD_COMMENT", PAGE_NFT, "1000000000000000000")

    console.log("setMinter: NFT_ADD_COMMENT")
    await PageAdmin.setMinter("NFT_ADD_COMMENT", PAGE_NFT, "1000000000000000000")
    */

    console.log("CHANGE OWNER SHIP")
    await PageAdmin.transferOwnership("0x73837Fd1188B7200f2c116cf475aC3D71928D26B")
    
    console.log("DEPLOYED")

    // LIST OF CONTRACTS:
    console.log('LIST OF CONTRACTS:')

    let PAGE_ADMIN = PageAdmin.address
    console.log("|- PAGE_ADMIN = ", PageAdmin.address )
    console.log("|- PAGE_TOKEN = ", PAGE_TOKEN )
    console.log("|- PAGE_NFT = ", PAGE_NFT )
    console.log("|- PAGE_MINTER = ", PAGE_MINTER )

    /*
    let PAGE_NFT_BANK = await PageAdmin.PAGE_NFT_BANK();
    console.log("|- PAGE_NFT_BANK = ", PAGE_NFT_BANK );

    let PAGE_NFT_MARKET = await PageAdmin.PAGE_NFT_MARKET();
    console.log("|- PAGE_NFT_MARKET = ", PAGE_NFT_MARKET );

    let PAGE_PROFILE = await PageAdmin.PAGE_PROFILE();
    console.log("|- PAGE_PROFILE = ", PAGE_PROFILE );
    */

    await saveContracts({
      PAGE_ADMIN:  PAGE_ADMIN,
      PAGE_TOKEN:  PAGE_TOKEN,
      PAGE_NFT:  PAGE_NFT,
      PAGE_MINTER:  PAGE_MINTER,
      // PAGE_NFT_BANK:  PAGE_NFT_BANK,
      // PAGE_NFT_MARKET:  PAGE_NFT_MARKET,
      // PAGE_PROFILE:  PAGE_PROFILE
    });
  
    // TEST ADMIN VERIFICATION
    // await verifyContracts(PageAdmin, "rinkeby");
    // console.log("FIN");

    /*
    PageAdmin deployed to: 0x94B12022ddFD2336E796663689bE518eec1A569d
    PageMinterNFT is deploying...
    PageMinterNFT deployed to: 0x820741c26Cab0799F4c8cA5e58e7c8701aDD2cd9

    |- PAGE_ADMIN =  0x774b03E220CC42d122353BD87927078C93D373d3
    |- PAGE_TOKEN =  0xE4C1915903846977FD05EE22A3Fa031774d486f8
    |- PAGE_NFT =  0xf9D158B5583b5183570722818AF4C8C1B2F7255e
    |- PAGE_MINTER =  0x774b03E220CC42d122353BD87927078C93D373d3
    |- PAGE_NFT_BANK =  0x0000000000000000000000000000000000000000
    |- PAGE_NFT_MARKET =  0x0000000000000000000000000000000000000000
    |- PAGE_PROFILE =  0x0000000000000000000000000000000000000000

    */

    /*
    PAGE_MINTER;
    PAGE_TOKEN;
    PAGE_NFT_BANK;
    PAGE_NFT_MARKET;
    PAGE_PROFILE;
    PAGE_NFT;
    */

  // PageMinterNFT = await deploy(ContractName);

  /*
    const _PageNFT = await ethers.getContractFactory("PageMinterNFT");
    const PageNFT = await _PageNFT.deploy();

    await PageAdmin.connect(PageAdmin.address).init(PageNFT.address);
  */

  /*
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