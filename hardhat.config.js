require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  paths: {
    artifacts: './artifacts',
  },
  networks: {
    hardhat: {
      chainId: 1337
    },
    polygon_mumbai: {
      url: "https://polygon-mumbai.g.alchemy.com/v2/fUwhr0s6kEpUl32JvgfMvB2TYy5QP-DD",
      accounts :[`0x${"f0617acd40ed6455775f3b666589627a87b9bc2c5596b49a721947168cf636d5"}`],
    },
  },
};
