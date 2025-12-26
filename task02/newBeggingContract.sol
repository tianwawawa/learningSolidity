// SPDX-License-Identifier: MIT
// 说明：指定合约的许可证类型为 MIT（开源许可，允许自由使用、修改和分发）
pragma solidity ^0.8;
// 说明：指定 Solidity 编译器版本 >=0.8.0 且 <0.9.0（兼容 0.8 系列所有版本，避免版本不兼容问题）


// 定义 ERC20 代币的接口（仅提取了 transfer 方法，简化版 IERC20 接口）
// 接口作用：声明合约需要实现的方法，这里用于和外部 ERC20 代币合约交互
interface IERC20 {
    // ERC20 代币转账方法：将指定 amount 数量的代币从当前合约地址转至 to 地址
    // 参数：to - 接收代币的地址；amount - 转账代币数量
    // 返回值：bool 类型，表示转账是否成功
    function transfer(address to, uint256 amount) external returns (bool);
}

// 定义合约名称为 FoundMe（众筹/资助类合约，核心实现项目创建、资助、提现等功能）
contract FoundMe {
    // ========== 结构体定义：用于封装相关数据 ==========
    // Project 结构体：存储单个项目的核心信息
    struct Project {
        string name;        // 项目名称
        uint256 goalAmount; // 项目目标资助金额（原生代币，如 ETH）
        string descption;   // 项目描述（注意：拼写错误，正确应为 description，不影响功能）
        uint256 received;   // 项目已接收的资助金额（原生代币）
    }

    // FoundRecord 结构体：存储单个项目的单笔资助记录
    struct FoundRecord {
        uint256 amount;    // 单笔资助的原生代币金额
        address founder;   // 资助者的钱包地址
    }

    // ========== 修饰器定义：用于权限控制/逻辑复用 ==========
    // onlyOwner 修饰器：限制方法仅合约所有者可调用
    // 修饰器作用：在被修饰的方法执行前，先校验调用者身份，不符合则直接报错回滚交易
    modifier onlyOwner() {
        // 校验：调用者地址（msg.sender）必须等于合约所有者地址（owner）
        // 若不相等，抛出错误提示 "only owner"，并终止交易
        require(msg.sender == owner, "only owner");
        _; // 占位符：表示执行被修饰方法的核心逻辑（修饰器校验通过后，才会执行方法体内容）
    }

    // ========== 状态变量定义：存储合约的持久化数据 ==========
    IERC20 public foundToken;
    // 说明：ERC20 代币合约实例（public 修饰，Solidity 自动生成对应的 foundToken() 只读方法，外部可查询代币地址）
    // 作用：通过该实例调用 ERC20 代币的 transfer 方法，实现代币转账

    address public owner;
    // 说明：合约所有者地址（public 修饰，自动生成 owner() 只读方法，外部可查询所有者地址）
    // 作用：记录合约部署者地址，用于权限控制（如 onlyOwner 修饰器校验）

    Project[] public projects;
    // 说明：项目数组（public 修饰，自动生成 projects(uint256 index) 只读方法，外部可根据索引查询项目信息）
    // 作用：存储所有创建的项目，数组索引作为项目的唯一标识（projectIndex）

    mapping(uint => FoundRecord[]) public foundRecords;
    // 说明：映射关系（Solidity 0.8.18+ 支持的新式映射语法）
    // 键（key）：uint 类型的项目索引（projectIndex）
    // 值（value）：FoundRecord 结构体数组，存储对应项目的所有资助记录
    // 作用：快速通过项目索引，查询该项目的所有资助明细（比数组遍历更高效）
    // public 修饰：自动生成 foundRecords(uint projectIndex) 方法，外部可查询对应项目的资助记录

    // ========== 构造函数：合约部署时仅执行一次 ==========
    // 构造函数：接收一个 ERC20 代币地址参数（foundTokenAddress）
    // 作用：初始化合约的核心状态变量
    constructor(address foundTokenAddress) {
        // 将传入的 ERC20 代币地址，初始化为 IERC20 合约实例，赋值给 foundToken 状态变量
        // 后续可通过 foundToken 调用该 ERC20 代币的 transfer 方法
        foundToken = IERC20(foundTokenAddress);
        // 将合约部署者的地址（msg.sender，部署合约时发起交易的地址）赋值给 owner 状态变量
        // 部署后，该地址即为合约所有者，拥有仅所有者可调用的方法权限
        owner = msg.sender;
    }

    // ========== 可写方法：创建项目 ==========
    // createProject：创建新的众筹项目
    // 参数：_name - 项目名称；_goal_amount - 项目目标金额；_descption - 项目描述
    // public：外部账户和其他合约均可调用
    // onlyOwner：修饰器，限制仅合约所有者可创建项目
    function createProject(string memory _name, uint256 _goal_amount, string memory _descption) public onlyOwner {
        // 向 projects 数组中添加一个新的 Project 结构体实例
        // 采用结构体简写初始化方式（字段顺序与 Project 定义一致：name → goalAmount → descption → received）
        // received 初始化为 0，表示项目初始时未接收任何资助
        projects.push(Project(_name, _goal_amount, _descption, 0));
    }

    // ========== 可写方法：资助项目 ==========
    // foundProject：向指定项目进行资助
    // 参数：projectIndex - 项目索引（对应 projects 数组的索引，指定要资助的项目）
    // public：外部账户和其他合约均可调用
    // payable：表示该方法可以接收原生代币（如 ETH）转账（调用方法时可附带原生代币）
    function foundProject(uint256 projectIndex) public payable {
        // 1. 记录资助记录：向 foundRecords 映射中，对应项目索引的数组添加一条新的资助记录
        // FoundRecord 结构体初始化：amount 为调用方法时附带的原生代币金额（msg.value）
        // founder 为调用者的地址（msg.sender，发起资助交易的地址）
        foundRecords[projectIndex].push(FoundRecord(msg.value, msg.sender));

        // 2. 代币奖励：调用 ERC20 代币的 transfer 方法，向资助者发放代币奖励
        // 转账接收者：msg.sender（资助者地址）
        // 转账金额：msg.value * 100（资助的原生代币金额 × 100，作为奖励代币数量）
        // 注：该方法依赖 ERC20 代币合约的 transfer 实现，若当前合约没有足够代币，该操作会失败回滚
        foundToken.transfer(msg.sender, msg.value * 100);
    }

    // ========== 可写方法：合约余额提现 ==========
    // withdraw：提取合约中所有的原生代币余额
    // public：外部账户和其他合约均可调用
    // onlyOwner：修饰器，限制仅合约所有者可提现
    function withdraw() public onlyOwner {
        // 1. 获取当前合约的原生代币余额（address(this) 表示当前合约自身的地址，balance 为该地址的原生代币余额）
        uint256 amount = address(this).balance;

        // 2. 将合约余额转账给调用者（msg.sender，即合约所有者）
        // payable(msg.sender)：将普通地址转换为可接收原生代币的 payable 地址
        // transfer(amount)：转账指定金额的原生代币，若转账失败（如合约余额不足），会自动回滚交易
        payable(msg.sender).transfer(amount);
    }

    // ========== 只读方法：查询项目资助记录 ==========
    // getFoundRedocrds：查询指定项目的所有资助记录（注意：拼写错误，正确应为 getFoundRecords）
    // 参数：projectIndex - 项目索引（指定要查询的项目）
    // public：外部账户和其他合约均可调用
    // view：只读方法，仅读取合约状态，不修改任何数据，执行时不消耗 Gas（除了首次调用的部署成本）
    // 返回值：FoundRecord[] memory - 资助记录数组（memory 表示临时存储，方法执行结束后释放）
    function getFoundRedocrds(uint256 projectIndex) public view returns(FoundRecord[] memory) {
        // 返回 foundRecords 映射中，对应项目索引的资助记录数组
        return foundRecords[projectIndex];
    }
}