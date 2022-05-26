async function main() {
  await hre.run('compile');

  const BoxV2Factory = await hre.ethers.getContractFactory('BoxV2');
  const boxV2Implementation = await BoxV2Factory.deploy();
  await boxV2Implementation.deployed();
  console.log('boxV2Implementation', boxV2Implementation.address);

  const ProxyAdminFactory = await hre.ethers.getContractFactory('ProxyAdmin');

  const proxyAdmin = await ProxyAdminFactory.attach('proxy_admin_address');

  console.log('proxyAdmin', proxyAdmin.address);

  await proxyAdmin.upgradeTo('proxy', boxV2Implementation.address);

  await hre.run('verify:verify', {
    address: boxV2Implementation.address,
  });
  console.log('Verified');
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
