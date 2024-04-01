require('@nomicfoundation/hardhat-toolbox')
require('dotenv').config()

module.exports = {
  solidity: '0.8.20',
  networks: {
    hardhat: {},
    bsctestnet: {
      url: 'https://data-seed-prebsc-1-s1.binance.org:8545/',
      accounts: [process.env.PRIVATE_KEY_TESTNET]
    },
    bsc: {
      url: 'https://bsc-dataseed.binance.org/',
      accounts: [process.env.PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: {
      bscTestnet: process.env.ETHERSCAN_BSC,
      bsc: process.env.ETHERSCAN_BSC
    }
  }
}
