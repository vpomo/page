const { isNull } = require('util');




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
  
      // STEP 1
      let PageProfile = await deploy('PageProfile', "0xcE65382a0a49C8b3Cf3C1C446d15DBAA14FCAb86")
      let PAGE_PROFILE = PageProfile.address
      console.log("|- PAGE_PROFILE = ", PAGE_PROFILE )
      await saveContracts({
        PAGE_PROFILE:  PAGE_PROFILE
      });
    }
    
    main()
      .then(() => process.exit(0))
      .catch((error) => {
        console.error(error);
        process.exit(1);
      });