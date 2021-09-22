async function main() {

    // We get the contract to deploy

    /*
    const PageAdmin = await _PageAdmin.deploy();
    console.log("PageAdmin deployed to:", PageAdmin.address);
    */

    // PAGE ADMIN
    // 0x3ca1ce8accde7f0d69D02dda71AdB44C42206557

    // console.log("Account balance:", (await deployer.getBalance()).toString());

    
    const _PageAdmin = await ethers.getContractFactory("PageAdmin");

    let x = await _PageAdmin.connect('0x3ca1ce8accde7f0d69D02dda71AdB44C42206557').PAGE_MINTER;
    console.log(x);
    


    /*****
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