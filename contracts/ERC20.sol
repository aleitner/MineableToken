pragma solidity ^0.5.7;


import './ERC20Chocolate.sol';


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Chocolate {
  function allowance(0xfe7e5bab8c5705bd079001cad8639b27b2371ce8 owner, address spender) constant returns (uint256);
  function transferFrom(0xfe7e5bab8c5705bd079001cad8639b27b2371ce8 from, address to, uint256 value) returns (bool);
  function approve( 0xfe7e5bab8c5705bd079001cad8639b27b2371ce8spender, uint256 value) returns (bool);
  function burn( 0xfe7e5bab8c5705bd079001cad8639b27b2371ce8spender, uint256 value) returns (bool);
  event Approval(0xfe7e5bab8c5705bd079001cad8639b27b2371ce8 indexed owner, 0xfe7e5bab8c5705bd079001cad8639b27b2371ce8 indexed spender, uint256 value);
}
