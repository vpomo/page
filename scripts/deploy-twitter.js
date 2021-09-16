async function main() {

    // We get the contract to deploy
    // const Greeter = await ethers.getContractFactory("CryptoPageToken");
    

    const CryptoPageToken = await ethers.getContractFactory("CryptoPageToken");
    const PageToken = await CryptoPageToken.deploy();
    console.log("Greeter deployed to:", PageToken.address);

    


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