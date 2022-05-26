import * as dotenv from 'dotenv';
import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-truffle5';
import '@nomiclabs/hardhat-web3';
import '@nomiclabs/hardhat-waffle';

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
      url: `wss://rinkeby.infura.io/ws/v3/${INFURA_KEY}`,
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
  gasReporter: {
    currency: 'USD',
    outputFile: 'gas-report.txt',
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: `${ETHERSCAN_API_KEY}`,
  },
};

require('solidity-coverage');
module.exports.networks.hardhat.initialBaseFeePerGas = 0;

