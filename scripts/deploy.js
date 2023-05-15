const hre = require("hardhat");

async function main() {
    const TricksContract = await hre.ethers.getContractFactory("Tricks");
    const tricksContract = await TricksContract.deploy("LesRemparts", "TRKS","ipfs://bafybeibnsoufr2renqzsh347nrx54wcubt5lgkeivez63xvivplfwhtpym/metadata.json");
    await tricksContract.deployed();
    console.log("Tricks contract deployed to:", tricksContract.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
