// The contract is deployed using the DEXCTOOL tool. Telegram: @dexcpro
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address initialOwner) {
        _owner = initialOwner;
        emit OwnershipTransferred(address(0), initialOwner);
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

contract ERC20 is Ownable {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _blacklist;
    bool public transferEnabled = true;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event BlacklistUpdated(address indexed account, bool isBlacklisted);
    event TransferEnabledUpdated(bool isEnabled);

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint8 tokenDecimals,
        uint256 initialSupply
    ) Ownable(msg.sender) {
        name = tokenName;
        symbol = tokenSymbol;
        decimals = tokenDecimals;
        _totalSupply = initialSupply * 10 ** uint256(decimals);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(!isBlacklisted(msg.sender), "ERC20: caller is blacklisted");
        require(!isBlacklisted(recipient), "ERC20: recipient is blacklisted");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            _balances[msg.sender] >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        require(transferEnabled, "ERC20: transfers are disabled");
        require(!isBlacklisted(sender), "ERC20: sender is blacklisted");
        require(!isBlacklisted(recipient), "ERC20: recipient is blacklisted");
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            _balances[sender] >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        require(
            _allowances[sender][msg.sender] >= amount,
            "ERC20: transfer amount exceeds allowance"
        );

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function addToBlacklist(address account) public onlyOwner {
        _blacklist[account] = true;
        emit BlacklistUpdated(account, true);
    }

    function removeFromBlacklist(address account) public onlyOwner {
        _blacklist[account] = false;
        emit BlacklistUpdated(account, false);
    }

    function isBlacklisted(address account) public view returns (bool) {
        return _blacklist[account];
    }

    function enableTransfers() public onlyOwner {
        transferEnabled = true;
        emit TransferEnabledUpdated(true);
    }

    function disableTransfers() public onlyOwner {
        transferEnabled = false;
        emit TransferEnabledUpdated(false);
    }
}
