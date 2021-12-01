// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import '@openzeppelin/contracts/access/Ownable.sol';

interface IERC20 {
  function balanceOf(address _user) external view returns(uint256);
  function transferFrom(address _user1, address _user2, uint256 amount) external ;  
  function transfer(address _user, uint256 amount) external;
}
contract Middle is Ownable {
  IERC20 public AToken;
  IERC20 public lpToken;

  // uint256 public constant dailyReward = 400 ether * 12 / 1000; //12% of 400 ftm
  mapping(address => uint256) public harvests;
  mapping(address => uint256) public lastUpdate;
  mapping(address => mapping(bool => uint256)) public amountOfOwner;
  uint256 public percent = 2;
  constructor (
    address ATokenAddr,
    address lpTokenAddr
  ) {
    AToken = IERC20(ATokenAddr);
    lpToken = IERC20(lpTokenAddr);
  }
  function stake(uint amount, bool categoryId) external payable {
    updateHarvest();
    if (categoryId == true) {
      AToken.transferFrom(msg.sender, address(this), amount);
    } else {
      lpToken.transferFrom(msg.sender, address(this), amount);
    }
    amountOfOwner[msg.sender][categoryId] += amount;
  }
  function withdraw(uint amount, bool categoryId) external payable {
    require(amountOfOwner[msg.sender][categoryId] >= amount, "withdraw amount exceed");
    updateHarvest();
    if(categoryId == true) {
      AToken.transfer(msg.sender, amount);
    } else {
      lpToken.transfer(msg.sender, amount);
    }
    amountOfOwner[msg.sender][categoryId] -= amount;
  } 
  function updateHarvest() internal {
    uint256 time = block.timestamp;
    uint256 timerFrom = lastUpdate[msg.sender];
    if (timerFrom > 0)
      harvests[msg.sender] += (amountOfOwner[msg.sender][true] + amountOfOwner[msg.sender][false]) * percent * (time - timerFrom) / 8640000;
    lastUpdate[msg.sender] = time;
  }
	function harvest() external payable {
    updateHarvest();
		uint256 reward = harvests[msg.sender];
		if (reward > 0) {
      AToken.transfer(msg.sender, harvests[msg.sender]);
			harvests[msg.sender] = 0;			
		}
	}  
  function setATokenAddr(address ATokenAddr) public onlyOwner {
    AToken = IERC20(ATokenAddr);
  }
  function setFtContractAddr(address lpTokenAddr) public onlyOwner {
    lpToken = IERC20(lpTokenAddr);
  }
  function getTotalClaimable() external view returns(uint256) {
    uint256 time = block.timestamp;
    uint256 pending = (amountOfOwner[msg.sender][true] + amountOfOwner[msg.sender][false]) * percent * (time - lastUpdate[msg.sender]) / 8640000;
    return harvests[msg.sender] + pending;
	}
}