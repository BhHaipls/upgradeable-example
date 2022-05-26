const hre = require('hardhat');
import { contractCode, permission, enums } from '../test/utils/property';

const DEV_PROXY_OWNER = '0xBFacA88a336a0728B7e18479731a31A8E0D9698d';
const DEV_ADMIN = '0x58Ce9c36a8aF6097F34eAa9c99e19cB53e0610BC';
const DEV_MULTIVEST = '0xB80933c642030020f26dEA39A1DB67A10f5359dA';
const WRAPPED_KRU = '0xeC844Bd12e042c080b57Dc1D2b5b5D921dEE3E95';
const UNISWAP_V2_FACTORY = '0x01b8A64E5de02faD0CB775F22AD7778a70eFBE75';
const UNISWAP_V2_ROUTER = '0x7c32fF25B5fF30ecc84858a7b485B8646dDb272B';
const UNISWAP_V2_PAIR = '0xdC1076f61432C1DCF358298F0B25147Ece0Bc900';
const KINGARU_TRESUARY = '0x58Ce9c36a8aF6097F34eAa9c99e19cB53e0610BC';

async function main() {
  await hre.run('compile');
  const ManagementUpgradeable = await hre.ethers.getContractFactory(
    'ManagementUpgradeable',
  );
  const KRUShopsManager = await hre.ethers.getContractFactory(
    'KRUShopsManager',
  );
  const KRUShopsPaymentProccesor = await hre.ethers.getContractFactory(
    'KRUShopsPaymentProccesor',
  );
  const KRUShopsPool = await hre.ethers.getContractFactory('KRUShopsPool');
  const TransparentUpgradeableProxy = await hre.ethers.getContractFactory(
    'TransparentUpgradeableProxy',
  );

  const managementImplementation = await ManagementUpgradeable.deploy();
  await managementImplementation.deployed();
  console.log('Management Implementation', managementImplementation.address);

  const managerImplementation = await KRUShopsManager.deploy();
  await managerImplementation.deployed();
  console.log('KRUShopsManager Implementation', managerImplementation.address);

  const proccesorImplementation = await KRUShopsPaymentProccesor.deploy();
  await proccesorImplementation.deployed();
  console.log(
    'KRUShopsPaymentProccesor Implementation',
    proccesorImplementation.address,
  );

  const poolImplementation = await KRUShopsPool.deploy();
  await poolImplementation.deployed();
  console.log('KRUShopsPool Implementation', poolImplementation.address);

  const managementProxy = await TransparentUpgradeableProxy.deploy(
    managementImplementation.address,
    DEV_PROXY_OWNER,
    [],
  );
  const managerProxy = await TransparentUpgradeableProxy.deploy(
    managerImplementation.address,
    DEV_PROXY_OWNER,
    [],
  );
  const proccesorProxy = await TransparentUpgradeableProxy.deploy(
    proccesorImplementation.address,
    DEV_PROXY_OWNER,
    [],
  );
  const poolProxy = await TransparentUpgradeableProxy.deploy(
    poolImplementation.address,
    DEV_PROXY_OWNER,
    [],
  );

  const management = await ManagementUpgradeable.attach(
    managementProxy.address,
  );
  const manager = await KRUShopsManager.attach(managerProxy.address);
  const proccesor = await KRUShopsPaymentProccesor.attach(
    proccesorProxy.address,
  );
  const pool = await KRUShopsPool.attach(poolProxy.address);

  await management.initialize();
  console.log('Management', management.address);

  await manager.initialize(management.address);
  console.log('KRUShopsManager', manager.address);

  await proccesor.initialize(management.address);
  console.log('KRUShopsPaymentProccesor', proccesor.address);

  await pool.initialize(management.address);
  console.log('KRUShopsPool', pool.address);

  await management.registerContract(
    contractCode.CONTRACT_KRU_SHOPS_MANAGER,
    manager.address,
  );
  await management.registerContract(
    contractCode.CONTRACT_KRU_SHOPS_PAYMENT_PROCCESOR,
    proccesor.address,
  );
  await management.registerContract(
    contractCode.CONTRACT_KRU_SHOPS_POOL,
    pool.address,
  );

  await management.registerContract(
    contractCode.CONTRACT_WRAPPED_KRU,
    WRAPPED_KRU,
  );
  await management.registerContract(
    contractCode.CONTRACT_UNISWAP_V2_FACTORY,
    UNISWAP_V2_FACTORY,
  );
  await management.registerContract(
    contractCode.CONTRACT_UNISWAP_V2_ROUTER,
    UNISWAP_V2_ROUTER,
  );
  await management.registerContract(
    contractCode.CONTRACT_UNISWAP_V2_PAIR,
    UNISWAP_V2_PAIR,
  );
  await management.registerContract(
    contractCode.CONTRACT_KRU_SHOPS_TRESUARY,
    DEV_ADMIN,
  );
  await management.registerContract(
    contractCode.CONTRACT_KRU_SHOPS_TRESUARY,
    KINGARU_TRESUARY,
  );
  console.log('Contracts registered!');

  await management.setPermissions(
    DEV_ADMIN,
    [
      permission.ROLE_ADMIN,
      permission.SHOPS_MANAGER_CAN_REGISTER_REMOVE_SHOP,
      permission.SHOPS_MANAGER_CAN_SET_COMMISION,
      permission.SHOPS_MANAGER_CAN_SET_SHOP_ACCESS,
    ],
    true,
  );

  await management.setPermissions(
    DEV_MULTIVEST,
    [
      permission.SHOPS_PAYMENT_PAY_SIGNER,
      permission.SHOPS_POOL_CAN_WITHDRAW_FOR,
    ],
    true,
  );

  console.log('Permissions setted!');

  await management.setLimitSetPermission(
    manager.address,
    permission.SHOPS_MANAGER_BLACK_LIST_PERM,
    true,
  );
  await management.setLimitSetPermission(
    manager.address,
    permission.SHOPS_MANAGER_FREEZE_LIST_PERM,
    true,
  );
  console.log('Limited permissions setted!');

  await manager.setRegisterMode(enums.REGISTER_MODE_AUTOMATIC);
  console.log('Register mode setted!');
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
