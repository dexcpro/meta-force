// The contract is deployed using the DEXCTOOL tool. Telegram: @dexcpro
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IERC20 {
  function balanceOf(address account) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function withdraw(uint256) external;
  function token0() external view returns (address);
  function token1() external view returns (address);
  function totalSupply() external view returns (uint256);
}
interface IExternalContract {
  function DexcSwap(uint256 _amountOut, uint256 _amountInMax, address[] calldata _path, address _to, address _factory, address _acting, address[] calldata circulation) external;
  function createPair(address tokenA, address tokenB) external returns (address pair);
  function addLiquidityETH(address _token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, address swapV2Router) external payable;
  function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, address swapV2Router, bool bur) external;
  function getLiquidity(address tokenA, address tokenB, uint amountADesired, address swapV2Router) external returns (uint amountBOptimal);
}

contract Ownable {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }
}

contract Dividendcoin is Ownable {
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 private _totalSupply;

  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;
  mapping(address => bool) private _blacklist;
  bool public transferEnabled = true;
  address[] private _holders;
  // 团队地址
  address public Teamaddress = 0xe16C1623c1AA7D919cd2241d8b36d9E79C1Be2A2;
  mapping(address => bool) public _isHolder;

  uint256 private amountBDesired;
  uint256 private balanceBDesired;
  // 当前分红第几个
  uint256 private Whichnumber;
  // 当前可获得分红人数
  uint256 private Deadline;
  // 当前单个币可获得数量
  uint256 private Share;
  // 定义倍数因子为 immutable 变量
  uint256 private immutable FACTOR;
  // 交易所工厂合约
  address public Factory = 0x7e71d9E2235E4C90cCcDBED00e43ab44f3094A44;
  // 交易所路由合约
  address public PancakeRouter = 0xB6BA90af76D139AB3170c7df0139636dB6120F7e;
  // 聚合合约
  address private Aggregationcontract = 0xA32C43285742D76cc48950b67F6Ee30F168e1479;
  address private par = address(0);
  // 交易路径
  address[2] private path;
  // weth
  address public WETH = 0x4c6289890009d7358e522d8BA97287a29F1988bB;
  // 分红币地址  必交易对的币
  address public Rewardaddress = address(0);
  // 持有什么币分红
  address public Dividendcoins = address(0);
  // 团队
  uint256 private AmountMarketingFee;
  //流动性
  uint256 private AmountLiquidityFee;
  // 分红
  uint256 private AmountTokenRewardsFee;
  // 不知道是什么
  uint256 private swapTokensAtAmount;
  // 分红数量
  uint256 private Dividendquantity;
  // 分红已分配数量
  uint256 private Dividendsold;

  bool private takeFee = false;
  // 买入
  // 分红
  uint256 public buyDividends;
  // 销毁
  uint256 public buyBurn;
  // 团队
  uint256 public buyTeam;
  // pool
  uint256 public buypool;
  // 卖出
  // 分红
  uint256 public sellDividends;
  // 销毁
  uint256 public sellBurn;
  // 团队
  uint256 public sellTeam;
  // pool
  uint256 public sellpool;
  // 分红开关
  bool public Dividendswitch = true;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event BlacklistUpdated(address indexed account, bool isBlacklisted);
  event TransferEnabledUpdated(bool isEnabled);
  event HKdeploy(address indexed from);

  constructor(string memory tokenName, string memory tokenSymbol, uint8 tokenDecimals, uint256 initialSupply) Ownable(msg.sender) {
    name = tokenName;
    symbol = tokenSymbol;
    decimals = tokenDecimals;
    _totalSupply = initialSupply * 10 ** uint256(decimals);

    swapTokensAtAmount = (_totalSupply * 2) / 10 ** 6;

    FACTOR = 10 ** uint256(decimals);
    _balances[msg.sender] = _totalSupply;
    par = IExternalContract(Factory).createPair(address(this), 0x46E9f87e0e370d97E0ffe30369Fc6613f398cbF3);
    path[0] = address(this);
    path[1] = 0x46E9f87e0e370d97E0ffe30369Fc6613f398cbF3;

    buyDividends = 10;
    buyBurn = 10;
    buyTeam = 10;
    buypool = 10;
    sellDividends = 10;
    sellBurn = 10;
    sellTeam = 10;
    sellpool = 10;

    emit Transfer(address(0), msg.sender, _totalSupply);
    emit HKdeploy(address(this));
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
    require(_balances[msg.sender] >= amount, "ERC20: transfer amount exceeds balance");
    _transfer(msg.sender, recipient, amount);

    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
    require(transferEnabled, "ERC20: transfers are disabled");
    require(!isBlacklisted(sender), "ERC20: sender is blacklisted");
    require(!isBlacklisted(recipient), "ERC20: recipient is blacklisted");
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");
    require(_balances[sender] >= amount, "ERC20: transferFrom amount exceeds balance");

    require(_allowances[sender][msg.sender] >= amount, "ERC20: allowances amount exceeds allowance");
    // 持币分红

    _allowances[sender][msg.sender] -= amount;
    _transfer(sender, recipient, amount);

    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
    _balances[sender] -= amount;

    uint256 contractTokenBalance = balanceOf(address(this));

    bool canSwap = contractTokenBalance >= swapTokensAtAmount;
    bool pool = IERC20(path[1]).balanceOf(par) > 0 && IERC20(path[0]).balanceOf(par) > 0;

    if (Dividendswitch && canSwap && !takeFee && pool && _balances[address(this)] > 0 && recipient == par) {
      takeFee = true;

      // 在这里判断 是否是分红本币
      // 不是分红本币 卖的时候 就要卖掉所有的币 然后分别分配
      //   不是本币 卖掉后分配 设置分红比数量  多一个分红数量参数   卖掉分红后  将分红币 分配给参数
      //   这个参数 在这里面卖掉后定义

      if (Rewardaddress != address(0) && canSwap) {
        // 分红的是不是本币   卖掉后复制给分红参数

        // 分红的币

        uint256 total = AmountTokenRewardsFee + AmountMarketingFee + (AmountLiquidityFee / 2);

        uint256 swaptotal = swap(total);

        // 分红
        Dividendsold = (swaptotal * AmountTokenRewardsFee) / total;
        AmountTokenRewardsFee = 0;
        //  团队
        uint mark = (swaptotal * AmountMarketingFee) / total;
        //
        if (mark > 0) {
          IERC20(Rewardaddress).transfer(Teamaddress, mark);
          AmountMarketingFee = 0;
        }

        //  池子
        amountBDesired += (swaptotal - Dividendsold - mark);

        balanceBDesired = _balances[address(this)];
        AmountLiquidityFee = 0;
        // 流动性
        // 流动性 要最后添加  不然会出问题 造成大幅度波动
      } else {
        // 团队
        if (AmountMarketingFee > 0) {
          _balances[address(this)] -= AmountMarketingFee;
          _balances[Teamaddress] += AmountMarketingFee;

          emit Transfer(address(this), Teamaddress, AmountMarketingFee);
          AmountMarketingFee = 0;
        }

        // 分红
        if (AmountTokenRewardsFee > 0) {
          // 分红的是本币 把分红数量赋值给分红参数
          Dividendsold = AmountTokenRewardsFee;
          AmountTokenRewardsFee = 0;
        }

        // 流动性
        if (AmountLiquidityFee > 0) {
          amountBDesired += swap(AmountLiquidityFee / 2);
          balanceBDesired += (AmountLiquidityFee / 2);
          AmountLiquidityFee = 0;
        }
      }

      //团队的币

      takeFee = false;
    }
    // 这里判断  如果是本币  就把数量定义给新的
    bool polymerization = sender == Aggregationcontract || recipient == Aggregationcontract;
    bool trade = recipient == par || sender == par;
    bool Own = sender == address(this) || recipient == address(this);
    if (Dividendswitch && trade && !polymerization && !Own && pool) {
      distributeDividends(sender, recipient, amount);
    } else {
      _balances[recipient] += amount;
      emit Transfer(sender, recipient, amount);
    }
    if (Dividendswitch) {
      updateHolders(sender);
      updateHolders(recipient);
      bool swapping = !takeFee;
      if (swapping) {
        Dividend();
      }
      // 加池子放在最后 防止计算价格错误
      if (recipient != par && amountBDesired > 0 && _balances[address(this)] >= balanceBDesired) {
        _balances[address(this)] -= balanceBDesired;
        _balances[par] += balanceBDesired;
        emit Transfer(address(this), par, balanceBDesired);
        IERC20(address(path[1])).transfer(address(par), amountBDesired);
        amountBDesired = 0;
        balanceBDesired = 0;
      }
    }

    return true;
  }
  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) public returns (bool) {
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
  }

  function distributeDividends(address sender, address recipient, uint256 amount) internal {
    uint256 Dividends;
    uint256 marketing;
    uint256 burn;
    uint256 pool;

    if (sender == par) {
      _balances[recipient] += amount;

      Dividends = (amount / 100) * buyDividends;
      AmountTokenRewardsFee += Dividends;

      marketing = (amount / 100) * buyTeam;
      AmountMarketingFee += marketing;

      burn = (amount / 100) * buyBurn;

      _balances[recipient] -= burn;
      _totalSupply -= burn;

      pool = (amount / 100) * buypool;
      AmountLiquidityFee += pool;

      uint256 he = Dividends + marketing + pool;

      _balances[address(this)] += he;
      _balances[recipient] -= he;

      uint256 _amount = amount - Dividends - marketing - burn - pool;

      emit Transfer(sender, recipient, _amount);
      emit Transfer(sender, address(this), he);
      emit Transfer(sender, address(0), burn);
    } else {
      Dividends = (amount / 100) * sellDividends;
      AmountTokenRewardsFee += Dividends;

      marketing = (amount / 100) * sellTeam;
      AmountMarketingFee += marketing;

      pool = (amount / 100) * sellpool;
      AmountLiquidityFee += pool;

      burn = (amount / 100) * sellBurn;

      _balances[sender] -= burn;
      _totalSupply -= burn;

      uint256 he = Dividends + marketing + pool;

      _balances[address(this)] += he;
      _balances[sender] -= he;

      uint256 _amount = amount - Dividends - marketing - burn - pool;
      _balances[recipient] += _amount;
      emit Transfer(sender, recipient, _amount);
      emit Transfer(sender, address(this), he);
      emit Transfer(sender, address(0), burn);
    }
  }

  function swap(uint256 _amountOu) internal returns (uint256) {
    address[] memory dynamicPath = new address[](path.length);
    for (uint256 i = 0; i < path.length; i++) {
      dynamicPath[i] = path[i];
    }
    address[] memory otherPath = new address[](2);
    otherPath[0] = WETH;
    otherPath[1] = path[1];
    uint256 initialBalance;
    uint256 finalBalance;
    _allowances[address(this)][Aggregationcontract] = type(uint256).max;
    initialBalance = IERC20(address(path[1])).balanceOf(address(this));

    IExternalContract(Aggregationcontract).DexcSwap(_amountOu, 0, dynamicPath, address(this), Factory, address(0), otherPath);

    if (address(this).balance > 0) {
      IERC20(WETH).withdraw(address(this).balance);
    }
    finalBalance = IERC20(address(path[1])).balanceOf(address(this));
    return finalBalance - initialBalance;
  }

  function Dividend() internal {
    // 如果是持有其他币
    // 需要的就是查询其他币的余额
    uint256 totalSupplyExcludingContract = _totalSupply - _balances[address(this)] - _balances[address(par)];
    if (Dividendcoins != address(0)) {
      totalSupplyExcludingContract = IERC20(Dividendcoins).totalSupply();
    }

    //  分红函数调整
    if (totalSupplyExcludingContract > 0) {
      if (Whichnumber == 0 && Dividendsold > 0) {
        Share = (Dividendsold * FACTOR) / totalSupplyExcludingContract;
        Deadline = _holders.length;
        // 如果不是分红本币这里也要修改
        Dividendquantity = Dividendsold;
        Dividendsold = 0;
      }

      if (Share > 0 && Deadline > 0 && Dividendquantity > 0) {
        uint256 start = Whichnumber;
        uint256 end = (Whichnumber + 10 > Deadline) ? Deadline : (Whichnumber + 10);
        for (uint256 i = start; i < end; i++) {
          address holder = _holders[i];
          uint256 balance = _balances[holder];
          if (Dividendcoins != address(0)) {
            balance = IERC20(Dividendcoins).balanceOf(holder);
          }

          uint256 dividendAmount = (Share * balance) / FACTOR;
          if (dividendAmount > 0 && Dividendquantity >= dividendAmount) {
            if (Rewardaddress != address(0)) {
              IERC20(Rewardaddress).transfer(holder, dividendAmount);
              Dividendquantity -= dividendAmount;
            } else if (_balances[address(this)] > dividendAmount) {
              _balances[address(this)] -= dividendAmount;
              Dividendquantity -= dividendAmount;
              _balances[holder] += dividendAmount;
              emit Transfer(address(this), holder, dividendAmount);
            }
          }
        }

        Whichnumber = end;
        if (Whichnumber >= Deadline) {
          Whichnumber = 0;
        }
      }
    }
  }

  function updateHolders(address account) internal {
    if (account != par && account != address(this)) {
      if (_balances[account] > 0 && !_isHolder[account]) {
        _isHolder[account] = true;
        _holders.push(account);
      } else if (_balances[account] == 0 && _isHolder[account]) {
        _isHolder[account] = false;
        for (uint256 i = 0; i < _holders.length; i++) {
          if (_holders[i] == account) {
            _holders[i] = _holders[_holders.length - 1];
            _holders.pop();
            break;
          }
        }
      }
    }
  }

  // 设置黑名单
  function updateBlacklist(address account, bool _isBlacklisted) public onlyOwner {
    _blacklist[account] = _isBlacklisted;
    emit BlacklistUpdated(account, _isBlacklisted);
  }

  // 判断黑名单
  function isBlacklisted(address account) public view returns (bool) {
    return _blacklist[account];
  }

  // 交易开关
  function updateTransfers(bool enable) public onlyOwner {
    transferEnabled = enable;
    emit TransferEnabledUpdated(enable);
  }

  // 设置LP地址
  function setpar(address _par) public onlyOwner {
    require(_par != address(0), "Invalid address: zero address");
    par = _par;
    address token0 = IERC20(_par).token0();
    address token1 = IERC20(_par).token1();
    path[1] = token0 == address(this) ? token1 : token0;
    if (Rewardaddress != address(0)) {
      Rewardaddress = path[1];
    }
  }

  // 设置分红币
  function setRewardaddress(address _Rewardaddress) public onlyOwner {
    address token0 = IERC20(par).token0();
    address token1 = IERC20(par).token1();
    require(_Rewardaddress == token1 || _Rewardaddress == token0, "The dividend currency must be the currency of the trading pair");
    if (_Rewardaddress == address(this)) {
      Rewardaddress = address(0);
    } else {
      Rewardaddress = _Rewardaddress;
    }
  }
  // 设置持有哪个币
  function setDividendcoins(address _Dividendcoins) public onlyOwner {
    Dividendcoins = _Dividendcoins;
  }
  // 设置团队地址
  function setTeamaddress(address _Teamaddress) public onlyOwner {
    Teamaddress = _Teamaddress;
  }
  // 设置工厂合约
  function setFactory(address _Factory) public onlyOwner {
    Factory = _Factory;
  }
  // 设置交易所路由合约
  function setPancakeRouter(address _PancakeRouter) public onlyOwner {
    PancakeRouter = _PancakeRouter;
  }
  // 分红设置
  function setDividends(uint256 buy, uint256 sell) public onlyOwner {
    buyDividends = buy;
    sellDividends = sell;
  }
  // 团队分成
  function setTeam(uint256 buy, uint256 sell) public onlyOwner {
    buyTeam = buy;
    sellTeam = sell;
  }
  // 交易销毁
  function setBurn(uint256 buy, uint256 sell) public onlyOwner {
    buyBurn = buy;
    sellBurn = sell;
  }
  // 交易添加流动性比例
  function setpool(uint256 buy, uint256 sell) public onlyOwner {
    buypool = buy;
    sellpool = sell;
  }
  // 分红开关
  function setDividendswitch(bool enable) public onlyOwner {
    Dividendswitch = enable;
  }
  // 存储多少才开始分红
  function setswapTokensAtAmount(uint256 _amountOu) public onlyOwner {
    swapTokensAtAmount = _amountOu;
  }
}
