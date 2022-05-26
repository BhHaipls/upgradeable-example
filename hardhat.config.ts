import * as dotenv from 'dotenv';
import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-truffle5';
import '@nomiclabs/hardhat-web3';
import '@nomiclabs/hardhat-waffle';
import '@nomiclabs/hardhat-etherscan';
import '@openzeppelin/hardhat-upgrades';

require('hardhat-gas-reporter');

dotenv.config();

const PRIVATE_KEY = process.env.PRIVATE_KEY
  ? process.env.PRIVATE_KEY
  : '0000000000000000000000000000000000000000000000000000000000000000';
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
const INFURA_KEY = process.env.INFURA_KEY;

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: '0.8.14',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  defaultNetwork: 'hardhat',

  networks: {
    hardhat: {
      blockGasLimit: 10000000,
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${INFURA_KEY}`,
      accounts: [`0x${PRIVATE_KEY}`]
    },
  },
  gasReporter: {
    currency: 'USD',
    outputFile: 'gas-report.txt',
  },
  etherscan: {
    apiKey: {
      rinkeby: `${ETHERSCAN_API_KEY}`,
    },
  },
};
