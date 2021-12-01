// SPDX-License-Identifier: MIT

pragma solidity ^ 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IToken {
  function balanceOf(address _user) external view returns(uint256);
  function transfer(address _user, uint256 amount) external ;  
}
contract Presale is Ownable {
  IToken public token;
  uint256 public constant PRESALE_ENTRIES = 1000 ether;
  uint256 private price =  0.05 ether;
  uint256 private whitelistPrice;
  uint8 private MAX_BUYABLE = 20;
  uint256 public saleAmount;
  uint256 public startTime;
  enum STAGES { PENDING, PRESALE }
  STAGES stage = STAGES.PENDING;
  mapping(address => bool) public whitelisted;
  uint256 public whitelistAccessCount;
  constructor(address tokenAddress) {
    token = IToken(tokenAddress );
    whitelistPrice = price * 90 / 100;
  }

  function buy(uint256 _amount) external payable {
    require(stage != STAGES.PENDING, "Presale not started yet.");
    require(saleAmount + _amount <= PRESALE_ENTRIES, "PRESALE LIMIT EXCEED");
    require(_amount <= MAX_BUYABLE, "BUYABLE LIMIT EXCEED");
    if (whitelisted[msg.sender]) {
      require(msg.value >= whitelistPrice * _amount, "need more money");
    } else {
      require(msg.value >= price * _amount, "need more money");
    }
    token.transfer(msg.sender, _amount * 1e18);
    saleAmount += _amount;
  }

  function addWhiteListAddresses(address[] calldata addresses) external onlyOwner
  {
    require(whitelistAccessCount + addresses.length <= 500, "Whitelist amount exceed");
    for (uint8 i = 0; i < addresses.length; i++)
    whitelisted[addresses[i]] = true;
    whitelistAccessCount += addresses.length;
  }

  function setWhitelistPrice(uint256 rePrice) external onlyOwner {
    whitelistPrice = rePrice;
  }
  
  function setPrice(uint256 rePrice) external onlyOwner {
    price = rePrice;
  }  

  function startSale() external onlyOwner {
    require(stage == STAGES.PENDING, "Not in pending stage.");
    startTime = block.timestamp;
    stage = STAGES.PRESALE;
  }

  function recoverCurrency(uint256 amount) public onlyOwner {
    bool success;
    (success, ) = payable(owner()).call{value: amount}("");
    require(success);
  }

  function recoverToken(uint256 tokenAmount) public onlyOwner {
    token.transfer(owner(), tokenAmount * 1e18);
  }
}
