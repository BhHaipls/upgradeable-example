const hre = require('hardhat');

async function main() {
  await hre.run('compile');

  const BoxV1Factory = await hre.ethers.getContractFactory('BoxV1');
  const boxV1Implementation = await BoxV1Factory.deploy();
  await boxV1Implementation.deployed();
  console.log('boxV1Implementation', boxV1Implementation.address);

  const ProxyAdminFactory = await hre.ethers.getContractFactory('ProxyAdmin');

  const proxyAdmin = await ProxyAdminFactory.deploy();
  await proxyAdmin.deployed();

  console.log('proxyAdmin', proxyAdmin.address);

  const TransparentUpgradeableProxy = await hre.ethers.getContractFactory(
    'TransparentUpgradeableProxy',
  );
  const proxy = await TransparentUpgradeableProxy.deploy(
    boxV1Implementation.address,
    proxyAdmin.address,
    [],
  );
  await proxy.deployed();

  const contract = await BoxV1Factory.attach(proxy.address);
  await contract.initialize(hre.ethers.utils.parseEther('0.01'));
  
  console.log('box1 Proxy', proxy.address);

  await hre.run('verify:verify', {
    address: boxV1Implementation.address,
  });
  await hre.run('verify:verify', {
    address: proxyAdmin.address,
  });
  await hre.run('verify:verify', {
    address: proxy,
    constructorArguments: [
      boxV1Implementation.address,
      proxyAdmin.address,
      '0x',
    ],
  });
  console.log('Verified');
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
