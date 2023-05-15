const hre = require("hardhat");

async function main() {
    const TricksContract = await hre.ethers.getContractFactory("tricks");
    const tricksContract = await TricksContract.deploy();
    await tricksContract.deployed();
    console.log("Tricks contract deployed to:", tricksContract.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
