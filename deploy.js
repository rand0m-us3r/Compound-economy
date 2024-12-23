async function main() {
  // This is just a convenience check
  if (network.name === "hardhat") {
    console.warn(
      "You are trying to deploy a contract to the Hardhat Network, which" +
        "gets automatically created and destroyed every time. Use the Hardhat" +
        " option '--network localhost'"
    );
  }

  // ethers is available in the global scope
  const [deployer, life_multisig] = await ethers.getSigners();
  console.log(
    "Deploying the contracts with the account:",
    await deployer.getAddress(),
    "life_multisig is:",
    await life_multisig.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const LifeToken = await ethers.getContractFactory("LifeToken");
  const lifeToken = await LifeToken.deploy(await life_multisig.getAddress());

  await lifeToken.deployed();

  console.log("Deployed LIFE contract to ", lifeToken.address);

  const LIVEToken = await ethers.getContractFactory("LiveToken");
  const LIVEToken = await LiveToken.deploy(lifeToken.address, await life_multisig.getAddress());

  await liveToken.deployed();

  console.log("Deployed live contract to ", liveToken.address);

  // Set sprout contract address in LIFE contract (to prevent accidental transfer())
  await lifeToken.connect(deployer).setLiveAddress(liveToken.address);
  console.log("Set LiveToken address in LifeToken contract");

  // We also save the contracts' artifacts and address in the frontend directory
  saveFrontendFiles(liveToken, lifeToken);
}

function saveFrontendFiles(liveToken, lifeToken) {
  const fs = require("fs");
  const contractsDir = __dirname + "/frontend/src/contracts";

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  fs.writeFileSync(
    contractsDir + "/eco-contract-address.json",
    JSON.stringify({ LifeToken: lifeToken.address }, undefined, 2)
  );

  fs.writeFileSync(
    contractsDir + "/sprout-contract-address.json",
    JSON.stringify({ LiveToken: liveToken.address }, undefined, 2)
  );

  fs.writeFileSync(
    contractsDir + "/EcoToken.json",
    JSON.stringify(artifacts.readArtifactSync("LifeToken"), null, 2)
  );

  fs.writeFileSync(
    contractsDir + "/LiveToken.json",
    JSON.stringify(artifacts.readArtifactSync("LiveToken"), null, 2)
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
