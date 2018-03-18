pragma solidity ^0.4.17;

import './BodhiToken.sol';

// 用于私募
contract CrowdsaleBodhiToken is BodhiToken {
    uint256 public constant nativeDecimals = 18; //这个小数点用于方便以太坊eth币的操作

    /// @notice 60 million BOT tokens for sale ，私募6千万
    uint256 public constant saleAmount = 60 * (10**6) * (10**decimals);

    // Crowdsale parameters
    uint256 public fundingStartBlock;
    uint256 public fundingEndBlock;
    uint256 public initialExchangeRate;

    // Events
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    /// @notice Creates new CrowdsaleBodhiToken contract
    /// @param _fundingStartBlock The starting block of crowdsale
    /// @param _fundingEndBlock The ending block of crowdsale
    /// @param _initialExchangeRate The exchange rate of Ether to BOT
    /// @param _presaleAmount The amount of BOT that will be available for presale（用来出售的token）
    function CrowdsaleBodhiToken(
        uint256 _fundingStartBlock,
        uint256 _fundingEndBlock,
        uint256 _initialExchangeRate,
        uint256 _presaleAmount) 
        public 
    {
        require(_fundingStartBlock >= block.number);
        require(_fundingEndBlock >= _fundingStartBlock);
        require(_initialExchangeRate > 0);

        // Converted to lowest denomination of BOT,转为最小单位
        uint256 presaleAmountTokens = _presaleAmount * (10**decimals);
        require(presaleAmountTokens <= saleAmount);

        assert(nativeDecimals >= decimals);

        fundingStartBlock = _fundingStartBlock;
        fundingEndBlock = _fundingEndBlock;
        initialExchangeRate = _initialExchangeRate;

        // Mint the presale tokens, distribute to a receiver
        // Increase the totalSupply accordingly
        mintByOwner(owner, presaleAmountTokens);  //用于销售的地址，放在owner地址
    }

    /// @notice Fallback function to purchase tokens
    function() external payable {
        buyTokens(msg.sender);
    }

    /// @notice Allows buying tokens from different address than msg.sender
    /// @param _beneficiary Address that will contain the purchased tokens
    function buyTokens(address _beneficiary) public payable {
        require(_beneficiary != address(0));
        require(block.number >= fundingStartBlock);
        require(block.number <= fundingEndBlock);
        require(msg.value > 0); //带有eth币

        uint256 tokenAmount = getTokenExchangeAmount(msg.value, initialExchangeRate, nativeDecimals, decimals);
        uint256 checkedSupply = totalSupply.add(tokenAmount);

        // Ensure new token increment does not exceed the sale amount
        assert(checkedSupply <= saleAmount);  //检查已经售出的

        mintByPurchaser(_beneficiary, tokenAmount);  //将token转入购买者地址
        TokenPurchase(msg.sender, _beneficiary, msg.value, tokenAmount);

        owner.transfer(msg.value);  //以太坊币交易
    }

    /// @notice Shows the amount of BOT the user will receive for amount of exchanged wei
    /// @param _weiAmount Exchanged wei amount to convert
    /// @param _exchangeRate Number of BOT per exchange token
    /// @param _nativeDecimals Number of decimals of the token being exchange for BOT
    /// @param _decimals Number of decimals of BOT token
    /// @return The amount of BOT that will be received
    function getTokenExchangeAmount(
        uint256 _weiAmount, 
        uint256 _exchangeRate,
        uint256 _nativeDecimals, 
        uint256 _decimals) 
        public
        pure 
        returns(uint256) 
    {
        require(_weiAmount > 0);

        uint256 differenceFactor = (10**_nativeDecimals) / (10**_decimals);
        return _weiAmount.mul(_exchangeRate).div(differenceFactor);
    }

    /// @dev Function to allow crowdsale participants to mint tokens when purchasing
    /// @param _to Address to mint the tokens to
    /// @param _amount Amount of tokens that will be minted
    /// @return Boolean to signify successful minting
    function mintByPurchaser(address _to, uint256 _amount) private returns (bool) {
        return mint(_to, _amount);
    }
}
