const hre = require("hardhat");

async function main() {

  const [owner] = await hre.ethers.getSigners();
  const contractFactory = await hre.ethers.getContractFactory("EmergencyJar");
  const contract = await contractFactory.deploy();
  await contract.deployed();

  console.log("EmergencyJar deployed to: ", contract.address);
  console.log("EmergencyJar owner address: ", owner.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
