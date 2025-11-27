// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
contract AlienToken {
    string private _name;
    string private _symbol;
    address public contractOwner;
    //每个地址的代币余额
    mapping(address=>uint256) private _balances;
    //账户余额和授权信息
    mapping(address=>mapping(address=>uint256)) private _allowance;
    //代币总供应量
    uint256 private _totalSupply;

    event Approval(address owner,address spender, uint256 value);
    event Transfer(address owner,address to, uint256 value);
    constructor(string memory name, string memory symbol){
        name = name;
        symbol = symbol;
        contractOwner = msg.sender;
    }

    // 查询代币总额 public
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    //查询账户余额 public
   function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    //代扣转账 public
    function transferFrom(address from, address to, uint256 value) public returns(bool){
        address spender = msg.sender;
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    //权限
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
    uint256 currentAllowance = _allowance[owner][spender];
    if (currentAllowance < type(uint256).max) {
    // 如果一开始就调用这个转账到这里就走到了revert了，因为强制要求先授权 在进行值的减少 否则就是负数了
        if (currentAllowance < value) {
            revert('insufficient allowance');
        }
        unchecked {
            _approve(owner, spender, currentAllowance - value, false);
        }
    }
}

    //自己转账
    function transfer(address to, uint256 value) public returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
    if (from == address(0)) {
        revert('invalid adress');
    }
    if (to == address(0)) {
        revert('invalid adress');
    }
    _update(from, to, value);
}

    function _update(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            _totalSupply+=value;
        } else {
            uint256 currentBalance = _balances[from];
            if(currentBalance < value) {
                revert('insufficient blalance');
            } 
            unchecked {
                _balances[from]= currentBalance - value;
            }
        }

        if (to == address(0)) {
            _totalSupply -= value;
        } else {
            unchecked {
            _balances[to] +=  value;
            }
        }
        emit Transfer(from, to, value);
    }

    //授权 public
    function approve(address spender, uint256 value) public returns(bool){
        address owner = msg.sender;
        _approve(owner, spender, value);
        return true;
    }
    function _approve(address owner, address spender, uint256 value) internal {
      _approve(owner, spender, value, true);
    }
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
    if (owner == address(0)) {
        revert('invalid adress');
    }
    if (spender == address(0)) {
        revert('invalid adress');
    }
    _allowance[owner][spender] = value;
    if (emitEvent) {
        emit Approval(owner, spender, value);
    }
}
    
    // mint external
    function mint(address account, uint256 value) external returns (bool) {
        require(msg.sender == contractOwner, 'only owner');
        if (account == address(0)) {
            revert('invalid receiver');
        }
        _update(address(0), account, value);
        return true;
    }

}