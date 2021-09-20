async function main() {

    // We get the contract to deploy
    // const Greeter = await ethers.getContractFactory("CryptoPageToken");
    
    const _PageAdmin = await ethers.getContractFactory("PageAdmin");
    const PageAdmin = await _PageAdmin.deploy();

    const _PageNFT = await ethers.getContractFactory("PageMinterNFT");
    const PageNFT = await _PageNFT.deploy();


    await greeter.connect(PageAdmin.address).init(PageNFT.address);
    
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