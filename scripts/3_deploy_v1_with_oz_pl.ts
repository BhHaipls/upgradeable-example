const { upgrades } = require('hardhat');

async function main() {
  await hre.run('compile');

  const Box = await hre.ethers.getContractFactory('BoxV1');
  let instance = await upgrades.deployProxy(Box, [], { initializer: false });

  await instance.deployed();
  instance = await Box.attach(instance.address);

  await instance.initialize(hre.ethers.utils.parseEther('0.01'));

  let implAddress = await upgrades.erc1967.getImplementationAddress(
    instance.address,
  );
  let proxyAdmin = await upgrades.erc1967.getImplementationAddress(
    instance.address,
  );

  console.log('box1 Proxy', instance.address);
  console.log('Implementation', implAddress);
  console.log('proxyAdmin', proxyAdmin);

  await hre.run('verify:verify', {
    address: implAddress,
  });
  await hre.run('verify:verify', {
    address: proxyAdmin,
  });
  await hre.run('verify:verify', {
    address: instance,
    constructorArguments: [instance.address, proxyAdmin, '0x'],
  });
  console.log('Verified');
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
