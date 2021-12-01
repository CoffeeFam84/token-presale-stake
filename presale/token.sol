// SPDX-License-Identifier: MIT

pragma solidity ^ 0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is Ownable, ERC20{
uint public price = 0.05 ether;
address public presaleContracAddr;
bool public isPresaleAddr; 
 constructor() ERC20("Token", "Token")  {
   isPresaleAddr = false;
 }

  function mint(uint256 _mintAmount) public payable { 
    require(msg.value >= price * _mintAmount, "Not enough funds!");
      _mint(msg.sender, _mintAmount * 1e18);
  }

  function mintOwner(uint256 ownerAmount) public payable onlyOwner {
    _mint(owner(), ownerAmount * 1e18);
  }

  function mintPresale(uint256 presaleAmount) public payable onlyOwner {
    require(isPresaleAddr, "add presale contract address");
    _mint(presaleContracAddr, presaleAmount * 1e18);      
  }

	function setContractAddress(address contractAddr) external onlyOwner(){
		presaleContracAddr = contractAddr;
    isPresaleAddr = true;
	}  
}