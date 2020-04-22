pragma solidity 0.6;
pragma experimental ABIEncoderV2;
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";

import "ballot_test.sol";




contract AuctionBox{
    
    Auction[] public auctions;
    using SafeMath for uint256;
    Auction a;
    TRC20 trc20;
    
    
    string index_;
    uint sale_price;
    uint sale_commission;
    bool isExist;
    uint _index=0;
    
    
    constructor() public{
        // address of contract tokens
        trc20 = TRC20(address(0x235F857D7947b9bC5Dc73f489B70Ef870e6263ed));
        
        
    }
    
    struct WalletOfGood{
        //string nameOfgood;
        uint amountOfgood;
        uint price;
        address addressOfgood;
        uint commission;
    }
    
    struct ChecksOfGood{
        string   nameOfGood ;
        uint     amountOfGood; 
        uint     Price  ;
        uint     sumPrice;
        address  address_transaction;
        string   timestamp;
    }
    
    struct isConfirmGiven_info{
        address addressOfgood;
        bool status;
    }
    
    mapping(address=>mapping(string=>WalletOfGood)) walletOfGoods;
    
    //address[] public userAccts;
    //string[] public userGoods;
    //address[] public goodChecks;
    uint[] confirmGivenArray;
    mapping(address=>mapping(uint=>ChecksOfGood)) checksOfGood;
    
    mapping(address=>string[]) nameOfGoods;
    mapping(address=>uint[]) indexesOfChecks;
    mapping(address=>mapping(uint=>isConfirmGiven_info)) isConfirmGiven;
    
   
    //_address_receipt = address of account
    function setChecksOfGoods(address _address_receipt, uint _index, string memory _nameOfgood, uint _amountOfGood,  uint _Price, uint _sumPrice, address  _address_transaction, string memory _timestamp) public{
        
        
        checksOfGood[_address_receipt][_index].nameOfGood = _nameOfgood;
        checksOfGood[_address_receipt][_index].amountOfGood = _amountOfGood;
        checksOfGood[_address_receipt][_index].Price = _Price;
        checksOfGood[_address_receipt][_index].sumPrice = _sumPrice;
        checksOfGood[_address_receipt][_index].address_transaction = _address_transaction;
        checksOfGood[_address_receipt][_index].timestamp = _timestamp;
        //goodChecks.push(_address_receipt);
        
        
    }
    //_address_receipt = address of account
    function getChecksOfGoods(address _address_receipt, uint _index) view public returns (string memory, uint, uint, uint, address, uint, string memory){
        address _a = _address_receipt;
        uint _i = _index;
        return (checksOfGood[_a][_i].nameOfGood, checksOfGood[_a][_i].amountOfGood, checksOfGood[_a][_i].Price, checksOfGood[_a][_i].sumPrice, checksOfGood[_a][_i].address_transaction, _index, checksOfGood[_a][_i].timestamp);
        ///////
        
    }
    
   
    //_address = address of account
    function settWalletOfGoods(address _address, string memory _nameOfgood, uint _amountOfgood, uint _price, address _addressOfgood, uint _commission) public{
        
        //user = walletOfGoods[_address];
        walletOfGoods[_address][_nameOfgood].price = _price;
        walletOfGoods[_address][_nameOfgood].amountOfgood += _amountOfgood;
        walletOfGoods[_address][_nameOfgood].addressOfgood = _addressOfgood;
        walletOfGoods[_address][_nameOfgood].commission = _commission;
        
        
        //userAccts.push(_address) -1;
    }
    //_address = address of account
    function setNameOfGoodFromWallet(address _address, string memory _title) public{
        isExist=false;
        for(uint i=0; i<nameOfGoods[_address].length; i++){
            
            if(keccak256(bytes(nameOfGoods[_address][i]))==keccak256(bytes(_title))){
                isExist=true;
            }
        }
        if (isExist==false){
             nameOfGoods[_address].push(_title);
             
        }
    }
    //_address = address of account
    function setIndexOfChecks(address _address, uint _index)public{
        indexesOfChecks[_address].push(_index);
    }
    
    //_address = address of account
    function setIsConfirmGiven(address _address, uint _index, address _addressOfgood, bool _status) public{
        isConfirmGiven[_address][_index].addressOfgood = _addressOfgood;
        isConfirmGiven[_address][_index].status = _status;
    }
    //_address = address of account
    function getIsConfirmGiven(address _address, uint _index) view public returns(address, bool){
        return (isConfirmGiven[_address][_index].addressOfgood, isConfirmGiven[_address][_index].status);
        
    }
    //_address = address of account
    function getNameOfGoodFromWallet(address _address) view public returns (string[] memory, uint){
        return (nameOfGoods[_address], nameOfGoods[_address].length);
    }
    
    
    //_address = address of account
    function getIndexOfChecksAndIsConfirm(address _address) view public returns(uint[] memory){
        return indexesOfChecks[_address];
    }
    
    /*function getWalletOfGoods() view public returns(address[] memory){
        return userAccts;
    }
    function getWalletOfGood(address _address, string memory _nameOfgood) view public returns (uint){
        return (walletOfGoods[_address][_nameOfgood].amountOfgood);
       
        
    }*/
    function getWalletOfGood_array(address _address, string memory _nameOfgood) view public returns (string memory, uint,uint, address, uint){
        return (_nameOfgood, walletOfGoods[_address][_nameOfgood].amountOfgood,walletOfGoods[_address][_nameOfgood].price, walletOfGoods[_address][_nameOfgood].addressOfgood, walletOfGoods[_address][_nameOfgood].commission);
        
    }
    
    
   
   function saleOfGoods(string memory _nameOfgood, uint _amountOfgood, address _addresOfgood) public{
       require(_amountOfgood<=walletOfGoods[msg.sender][_nameOfgood].amountOfgood);
       trc20 = TRC20(address(0x235F857D7947b9bC5Dc73f489B70Ef870e6263ed));
       a = Auction(address(_addresOfgood));
       a.setCount(_amountOfgood);
       walletOfGoods[msg.sender][_nameOfgood].amountOfgood = walletOfGoods[msg.sender][_nameOfgood].amountOfgood.sub(_amountOfgood);
       
       
       trc20.approve(address(this), msg.sender, walletOfGoods[msg.sender][_nameOfgood].price.mul(100000000).mul(_amountOfgood).sub(walletOfGoods[msg.sender][_nameOfgood].commission.mul(1000000).mul(_amountOfgood)));
       // Move to tokens to contract address
       trc20.transfer(msg.sender, walletOfGoods[msg.sender][_nameOfgood].price.mul(100000000).mul(_amountOfgood).sub(walletOfGoods[msg.sender][_nameOfgood].commission.mul(1000000).mul(_amountOfgood)));
       
       if(walletOfGoods[msg.sender][_nameOfgood].amountOfgood==0){
           for(uint i=0; i<nameOfGoods[msg.sender].length; i++){
            if(keccak256(bytes(nameOfGoods[msg.sender][i]))==keccak256(bytes(_nameOfgood))){
                delete nameOfGoods[msg.sender][i];
            }
        }
       }
       
   }
   
   //_addresses = address Of goods
   function saleOfGoodsBox(string[] memory _nameOfgoods, uint[] memory _amountOfgoods, address[] memory _addresses)public {
       for(uint i=0; i<_addresses.length; i++){
          saleOfGoods(_nameOfgoods[i], _amountOfgoods[i], _addresses[i]);
           
       }
   }
   
   
   function placeBidBox(address[] memory _addresses, uint[] memory _amounts, string memory _timestamp)public{
      
       
       for(uint i=0; i<_addresses.length; i++){
           a = Auction(address(_addresses[i]));
           a.placeBid(_amounts[i], msg.sender, _timestamp);
           
       }

   }
   function finalizeBox(address[] memory _addresses, uint[] memory _indexes)public{
        for(uint i=0; i<_addresses.length; i++){
            a = Auction(address(_addresses[i]));
            a.finalizeAuction( msg.sender, _indexes[i]);
   }
   }
   //addresses = addresses auction
   function cancelConfirmBox(address[] memory _addresses, uint[] memory _indexes)public{
       for(uint i=0; i<_addresses.length; i++){
            a = Auction(address(_addresses[i]));
            a.cancelConfirm(msg.sender, _indexes[i]);
   }
   }
   
   
   
   function balanceOf(address account)  external view returns(uint256){
        
        uint256 balance = trc20.balanceOf(account);
        return balance;
    }
    
    function addIndex() public returns(uint){
        return _index+=1;
    }
   
   
     
   
    function createAuction (
        string memory _title,
        uint _startPrice,
        string memory _description,
        uint _count,
        uint _commission
        )payable public{
        Auction newAuction = new Auction(msg.sender, address(this), _title, _startPrice, _description, _count, _commission);
        // push the auction address to auctions array
        auctions.push(newAuction);
        
    }
    
    function returnAllAuctions() public view returns(Auction[] memory){
        return auctions;
    }
    
    /*function getAddressBox() public view returns(address){
        return address(this);
    }*/
    
}
contract Auction {

    TRC20 trc20;
    AuctionBox  ab;
    using SafeMath for uint256;
    address payable public owner; 
    string title;
    uint startPrice;
    string description;
    uint public count;
    uint commission;
    uint constPrice;
    uint commisionConst;
    uint public blockNumber;
    bytes32 public blockHashNow;
    bytes32 public blockHashPrevious;
    uint _index=0;
    bool isExist;
    enum State{Default, Running, Finalized}
    State public auctionState;
    
    uint public highestPrice;
    address payable public highestBidder;
    mapping(address => mapping(uint=>uint)) public bids;
    mapping(address => uint) public goods;
    
   
    
    
      
    constructor(
        address payable _owner,
        address _addressBox,
        string memory _title,
        uint _startPrice,
        string memory _description,
        uint  _count,
        uint _commission
        
        ) public {
        // initialize auction
        owner = _owner;
        title = _title;
        startPrice = _startPrice;
        description = _description;
        count = _count;
        commission = _commission;
        auctionState = State.Running;
        constPrice = startPrice;
        commisionConst = commission;
        trc20 = TRC20(address(0x235F857D7947b9bC5Dc73f489B70Ef870e6263ed));
        ab = AuctionBox(_addressBox);
        
    }
    
    modifier notOwner(){
        require(msg.sender != owner);
        _;
    }
    

    
    
    
    
   
    
    function setCount(uint _count) public {
        count =count.add(_count);
        
    }
    
    
    
    
    // buy goods
    function placeBid(uint amount, address _address, string memory _timestamp)  public notOwner returns(bool) {
        require(auctionState == State.Running);
        require(count>=amount);
        
        _index = ab.addIndex();
        
        goods[_address] = goods[_address].add(amount);
        startPrice = startPrice.mul(100000000).mul(amount).add(commission.mul(1000000).mul(startPrice).mul(amount));
        
        bids[_address][_index] = bids[_address][_index].add(startPrice);
        
        trc20.approve(_address, address(this), startPrice);
        // Move to tokens to contract address
        trc20.transferFrom(_address, address(this), startPrice);
        count = count.sub(amount);
        ab.settWalletOfGoods(_address, title, amount, constPrice, address(this), commisionConst);
        ab.setNameOfGoodFromWallet(_address, title);
        ab.setChecksOfGoods(_address, _index, title, amount, constPrice, startPrice.div(100000000), address(this), _timestamp);
        ab.setIndexOfChecks(_address, _index);
        ab.setIsConfirmGiven(_address, _index, address(this), false);
        
        startPrice=constPrice;
        
        return true;
}
    
    

    
    
    
   
    //confirm given good
     function finalizeAuction(address _address, uint _index) payable public{
        //the owner and bidders can finalize the auction.
        require(_address == owner || bids[_address][_index] > 0);
        
        address payable recipiant;
        uint value;
        
        // owner can get highestPrice
        if(_address == owner){
            value = 0;
            
        }
    
        // Other bidders can get back the money 
        else {
            value =  bids[_address][_index];
        }
        // initialize the value
        bids[_address][_index] = 0;
        //recipiant.transfer(value);
        trc20.approve(address(this), owner, value);
        
        trc20.transfer(owner, value);
        ab.setIsConfirmGiven(_address, _index, address(this), true);
        if(count<=0){
            auctionState = State.Finalized;
        }
        
    }
    
    function cancelConfirm(address _address, uint _index) payable public{
        require(_address == owner || bids[_address][_index] > 0);
        
        address payable recipiant;
        uint value;
        
        // owner can get highestPrice
        if(_address == owner){
            value = 0;
            
        }
    
        // Other bidders can get back the money 
        else {
            value =  bids[_address][_index];
        }
        // initialize the value
        bids[_address][_index] = 0;
        //recipiant.transfer(value);
        trc20.approve(address(this), _address, value);
        
        trc20.transfer(_address, value);
        
        
    }
    
    
    
    function returnContents() public view returns(        
        string memory,
        uint,
        string memory,
        uint,
        uint,
        State
        ) {
        return (
            title,
            startPrice,
            description,
            count,
            commission,
            auctionState
        );
    }
}






