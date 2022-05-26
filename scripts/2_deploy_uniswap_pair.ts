const hre = require('hardhat');

import { toETH, getCurrentTimestamp } from '../test/utils/utils';
import { Signer } from 'ethers';

import * as UniswapV2FactoryBuild from '@uniswap/v2-core/build/UniswapV2Factory.json';
import * as UniswapV2Router02Build from '@uniswap/v2-periphery/build/UniswapV2Router02.json';
import * as UniswapV2PairBuild from '../node_modules/@uniswap/v2-core/build/UniswapV2Pair.json';

const DEV_ADMIN = '0x58Ce9c36a8aF6097F34eAa9c99e19cB53e0610BC';
const DEV_USDK = '0x5a95bb13a145c193ba3d0b421d99cd519508b573';
const KINGARU_TRESUARY = '0x58Ce9c36a8aF6097F34eAa9c99e19cB53e0610BC';
const START_KRU_LIQUIDITY = toETH(1000000);
const START_USDK_LIQUIDITY = toETH(100000);

async function main() {
  await hre.run('compile');
  let owner: Signer;
  [owner] = await hre.ethers.getSigners();

  const WKRU = await hre.ethers.getContractFactory('WKRU');
  const ERC20 = await hre.ethers.getContractFactory('ERC20Mock');
  const UniswapV2Factory = new hre.ethers.ContractFactory(
    UniswapV2FactoryBuild.abi,
    UniswapV2FactoryBuild.bytecode,
    owner,
  );
  const UniswapV2Router02 = new hre.ethers.ContractFactory(
    UniswapV2Router02Build.abi,
    UniswapV2Router02Build.bytecode,
    owner,
  );
  const UniswapV2Pair = new hre.ethers.ContractFactory(
    UniswapV2PairBuild.abi,
    UniswapV2PairBuild.bytecode,
    owner,
  );

  const usdk = await ERC20.attach(DEV_USDK);
  console.log('USDK:', usdk.address);
  const wrappedKRU = await WKRU.deploy();
  await wrappedKRU.deployed();
  console.log('Wrapped KRU:', wrappedKRU.address);

  const factory = await UniswapV2Factory.deploy(KINGARU_TRESUARY);
  await factory.deployed();
  console.log('UniswapV2Factory:', factory.address);
  const router = await UniswapV2Router02.deploy(
    factory.address,
    wrappedKRU.address,
  );
  await router.deployed();
  console.log('UniswapV2Router02:', router.address);

  await usdk.approve(router.address, START_USDK_LIQUIDITY);
  await wrappedKRU.approve(router.address, START_KRU_LIQUIDITY);
  await router.addLiquidityETH(
    usdk.address,
    START_USDK_LIQUIDITY,
    toETH(1),
    toETH(1),
    DEV_ADMIN,
    (await getCurrentTimestamp()) + 1000,
    { value: START_KRU_LIQUIDITY },
  );

  const pair = await UniswapV2Pair.attach(await factory.allPairs(0));
  console.log('UniswapV2Pair:', pair.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
