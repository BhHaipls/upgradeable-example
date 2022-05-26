const { upgrades } = require('hardhat');

async function main() {
  await hre.run('compile');

  const BoxV2 = await hre.ethers.getContractFactory('BoxV2');
  await upgrades.upgradeProxy('your_proxy_address', BoxV2);

  let implAddress = await upgrades.erc1967.getImplementationAddress(
    'your_proxy_address',
  );

  console.log('Implementation V2', implAddress);

  await hre.run('verify:verify', {
    address: implAddress,
  });
  await hre.run('verify:verify', {
    address: implAddress,
  });
  console.log('Verified');
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
