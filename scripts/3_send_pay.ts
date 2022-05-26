const hre = require('hardhat');
const { ethers } = require('hardhat');

import { contractCode, permission } from '../test/utils/property';
import {
  a,
  DOMAON_TYPE,
  toETH,
  getCurrentTimestamp,
  setCurrentTime,
  snapshot,
  restore,
} from '../test/utils/utils';
import { Contract, Signer } from 'ethers';

async function main() {
  await hre.run('compile');
  let owner: Signer;
  [owner] = await hre.ethers.getSigners();

  const KRUShopsPaymentProccesor = await hre.ethers.getContractFactory(
    'KRUShopsPaymentProccesor',
  );
  const proccesor = await KRUShopsPaymentProccesor.attach(
    '0x103A902e7847Ac3b24DaDeC82796A8173aaa45F5',
  );


  const DOMAON_TYPE = [
    {
      type: 'string',
      name: 'name',
    },
    {
      type: 'string',
      name: 'version',
    },
    {
      type: 'uint256',
      name: 'chainId',
    },
    {
      type: 'address',
      name: 'verifyingContract',
    },
  ];
  const TYPES = {
    Container: [
      {
        name: 'orderId',
        type: 'string',
      },
      {
        name: 'shop',
        type: 'address',
      },
      {
        name: 'sender',
        type: 'address',
      },
      {
        name: 'usdAmount',
        type: 'uint256',
      },
      {
        name: 'deadline',
        type: 'uint256',
      },
    ],
  };
  let sign = await ethers.provider.send('eth_signTypedData_v4', [
    await a(owner),
    JSON.stringify({
      types: Object.assign(
        {
          EIP712Domain: DOMAON_TYPE,
        },
        TYPES,
      ),
      domain: {
        name: 'KRUShopsPaymentProccesor',
        version: 'v1',
        chainId: 1717,
        verifyingContract: '0x103A902e7847Ac3b24DaDeC82796A8173aaa45F5',
      },
      primaryType: 'Container',
      message: {
        orderId: '45c82009-a1bb-4938-a6c7-1ef46c4d6c4f',
        shop: '0xc4E14d8de52A69Af34b26E218092638093F05923',
        sender: '0x74736ee1590f758cb0e05657ce62b83ece9ce5e5',
        usdAmount: toETH(121),
        deadline: 1649425727,
      },
    }),
  ]);
  const sig = sign;
  const sig0 = sig.substring(2);
  const r = '0x' + sig0.substring(0, 64);
  const s = '0x' + sig0.substring(64, 128);
  const v = parseInt(sig0.substring(128, 130), 16);
  console.log('v', v);
  console.log('r', r);
  console.log('s', s);

  await proccesor.pay(
    '45c82009-a1bb-4938-a6c7-1ef46c4d6c4f',
    '0xc4e14d8de52a69af34b26e218092638093f05923',
    '121000000000000000000',
    1649425727,
    28,
    "0x3aa3b1ae53583a61d8b40a2b36be50d6e92c02d9bf90aa474a3b9193e2c5e64a",
    "0x24eb52f98192f9bce9a0fa03c1fad1449b6d52379621411e0ccfffc3c294db1b",
    { value: toETH(1210) },
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
