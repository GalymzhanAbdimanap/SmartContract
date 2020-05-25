pragma solidity 0.5.9;
pragma experimental ABIEncoderV2;
//import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "safeMath.sol";
import "Token-contract.sol";




contract AuctionBox{
    
    //Auction[] public auctions;
    using SafeMath for uint256;
    //Auction a;
    TRC20 trc20;
    
    
    string index_;
    uint sale_price;
    uint sale_commission;
    bool isExist;
    uint _index=0;
    
    uint256 add_token = 0x411576d1a39ace4f0a24fc52b7a17be97904f6a2b8;
    enum State{Default, Running, Finalized}
    State public auctionState;
    
    
    
    
    //contract Auctions
    uint public count;
    address owner = msg.sender;
    uint _index_auctions=0;
    uint startPrice;
    string description;
    uint commission;
    uint constPrice;
    uint commisionConst;
    
    //uint _index=0;
    //bool isExist;
    
    uint public highestPrice;
    address payable public highestBidder;
    mapping(uint=>mapping(address => mapping(uint=>uint))) public bids;
    mapping(uint=>mapping(address => mapping(uint=>uint))) public bids_goods;
    mapping(uint=>mapping(address => uint)) public goods;
    mapping(uint=>State) public aucStates;
    
    
    
    
    
    
    
    
    function convertFromTronInt(uint256 tronAddress) public view returns(address){
      return address(tronAddress);
    }
    
    
    constructor() public{
        // address of contract tokens
        trc20 = TRC20(address(add_token));
        
        
    }
    
    struct WalletOfGood{
        string nameOfgood;
        uint amountOfgood;
        uint price;
        uint addressOfgood;
        uint commission;
    }
    
    struct ChecksOfGood{
        string[]   nameOfGood ;
        uint[]     amountOfGood; 
        uint[]     Price  ;
        uint[]     sumPrice;
        address[]  address_transaction;
        string   timestamp;
        bool     status;
        uint allSumPrice;
        string type_op;
    }
    
    struct Auctions{
        string  title;
        uint startPrice;
        string  description;
        uint  count;
        uint commission;
        
    }
    mapping(uint=>Auctions) AllAuctions;
    
    
    
    mapping(address=>mapping(uint=>WalletOfGood)) walletOfGoods;
    
    
    uint[] confirmGivenArray;
    mapping(address=>mapping(uint=>ChecksOfGood)) checksOfGood;
    
    mapping(address=>uint[]) addressOfGoods;
    mapping(address=>uint[]) indexesOfChecks;
    
     
   
    //_address_receipt = address of account
    function setChecksOfGoods(address _address_receipt, uint _index, string memory _nameOfgood, uint _amountOfGood,  uint _Price, uint _sumPrice, address  _address_transaction, string memory _timestamp, bool _status, string memory _type_op) public{
        
        
        checksOfGood[_address_receipt][_index].nameOfGood.push(_nameOfgood);
        checksOfGood[_address_receipt][_index].amountOfGood.push(_amountOfGood);
        checksOfGood[_address_receipt][_index].Price.push(_Price);
        checksOfGood[_address_receipt][_index].sumPrice.push(_sumPrice);
        checksOfGood[_address_receipt][_index].address_transaction.push(_address_transaction);
        checksOfGood[_address_receipt][_index].timestamp = _timestamp;
        checksOfGood[_address_receipt][_index].status = _status;
        checksOfGood[_address_receipt][_index].allSumPrice = checksOfGood[_address_receipt][_index].allSumPrice.add(_sumPrice);
        checksOfGood[_address_receipt][_index].type_op = _type_op;
        //goodChecks.push(_address_receipt);
        
        
    }
    //_address_receipt = address of account
    function getChecksOfGoods(address _address_receipt, uint _index) view public returns (string [] memory, uint[] memory, uint[] memory, uint[] memory, address[] memory, uint, string memory, bool, uint, string memory){
        address _a = _address_receipt;
        uint _i = _index;
        
        return (checksOfGood[_a][_i].nameOfGood, checksOfGood[_a][_i].amountOfGood, checksOfGood[_a][_i].Price, checksOfGood[_a][_i].sumPrice, checksOfGood[_a][_i].address_transaction, _i, checksOfGood[_a][_i].timestamp, checksOfGood[_a][_i].status, checksOfGood[_a][_i].allSumPrice, checksOfGood[_a][_i].type_op);
        ///////
        
    }
    
   
    //_address = address of account
    function settWalletOfGoods(address _address, uint _id_auction, string memory _nameOfgood, uint _amountOfgood, uint _price, uint _commission) public{
        
        //user = walletOfGoods[_address];
        walletOfGoods[_address][_id_auction].nameOfgood = _nameOfgood;
        walletOfGoods[_address][_id_auction].price = _price;
        walletOfGoods[_address][_id_auction].amountOfgood += _amountOfgood;
        walletOfGoods[_address][_id_auction].addressOfgood = _id_auction;
        walletOfGoods[_address][_id_auction].commission = _commission;
        
        
        //userAccts.push(_address) -1;
    }
    //_address = address of account
    function setNameOfGoodFromWallet(address _address, uint _id_auction) public{
        isExist=false;
        for(uint i=0; i<addressOfGoods[_address].length; i++){
            
            if(addressOfGoods[_address][i]==_id_auction){
                isExist=true;
            }
        }
        if (isExist==false){
             addressOfGoods[_address].push(_id_auction);
             
        }
    }
    //_address = address of account
    function setIndexOfChecks(address _address, uint _index)public{
        indexesOfChecks[_address].push(_index);
    }
    
    
    
    function setIsConfirmGiven(address _address, uint _index) public{
        checksOfGood[_address][_index].status = true;
    }
    
    
    
    //_address = address of account
    function getAddressOfGoodFromWallet(address _address) view public returns (uint[] memory, uint){
        return (addressOfGoods[_address], addressOfGoods[_address].length);
    }
    
    
    //_address = address of account
    function getIndexOfChecksAndIsConfirm(address _address) view public returns(uint[] memory){
        return indexesOfChecks[_address];
    }
    
    
    function getWalletOfGood_array(address _address, uint _id_auction) view public returns (string memory, uint,uint, uint, uint){
        return (walletOfGoods[_address][_id_auction].nameOfgood, walletOfGoods[_address][_id_auction].amountOfgood,walletOfGoods[_address][_id_auction].price, walletOfGoods[_address][_id_auction].addressOfgood, walletOfGoods[_address][_id_auction].commission);
        
    }
    
    

   
   function saleOfGoods(uint _id_auction, uint _amountOfgood) public{
       require(_amountOfgood<=walletOfGoods[msg.sender][_id_auction].amountOfgood);
       trc20 = TRC20(address(0x411576d1a39ace4f0a24fc52b7a17be97904f6a2b8));
       //a = Auction(address(_addresOfgood));
       setCountAdd(_id_auction, _amountOfgood);
       walletOfGoods[msg.sender][_id_auction].amountOfgood = walletOfGoods[msg.sender][_id_auction].amountOfgood.sub(_amountOfgood);
       
       
       trc20.approve(address(this), msg.sender, walletOfGoods[msg.sender][_id_auction].price.mul(100000000).mul(_amountOfgood).sub(walletOfGoods[msg.sender][_id_auction].commission.mul(1000000).mul(_amountOfgood)));
       // Move to tokens to contract address
       trc20.transfer(msg.sender, walletOfGoods[msg.sender][_id_auction].price.mul(100000000).mul(_amountOfgood).sub(walletOfGoods[msg.sender][_id_auction].commission.mul(1000000).mul(_amountOfgood)));
       
       if(walletOfGoods[msg.sender][_id_auction].amountOfgood==0){
           for(uint i=0; i<addressOfGoods[msg.sender].length; i++){
            if(addressOfGoods[msg.sender][i]==_id_auction){
                delete addressOfGoods[msg.sender][i];
            }
        }
       }
       
   }
   
   //_addresses = address Of goods
   function saleOfGoodsBox(string[] memory _nameOfgoods, uint[] memory _amountOfgoods, uint[] memory _id_auctions)public {
       for(uint i=0; i<_id_auctions.length; i++){
          saleOfGoods(_id_auctions[i], _amountOfgoods[i]);
           
       }
   }
   
   
   function placeBidBox(uint[] memory _id_auctions, uint[] memory _amounts, string memory _timestamp)public{
       _index = addIndex();
       
       for(uint i=0; i<_id_auctions.length; i++){
           //a = Auction(address(_addresses[i]));
           placeBid(_id_auctions[i], _amounts[i], msg.sender, _timestamp, _index);
           
       }
       setIndexOfChecks(msg.sender, _index);

   }
   function finalizeBox(uint[] memory _id_auctions, uint _index)public{
        for(uint i=0; i<_id_auctions.length; i++){
            //a = Auction(address(_addresses[i]));
            finalizeAuction(_id_auctions[i], msg.sender, _index);
   }
   }
   //addresses = addresses auction
   /*function cancelConfirmBox(address[] memory _addresses, uint[] memory _indexes)public{
       for(uint i=0; i<_addresses.length; i++){
            a = Auction(address(_addresses[i]));
            a.cancelConfirm(msg.sender, _indexes[i]);
   }
   }*/
   
   
   
   function balanceOf(address account)  external view returns(uint256){
        
        uint256 balance = trc20.balanceOf(account);
        return balance;
    }
    
    function addIndex() public returns(uint){
        return _index+=1;
    }
   
   
     
   
    
    
    function createAuction(
        string memory _title,
        uint _startPrice,
        string memory _description,
        uint  _count,
        uint _commission) payable public{
            AllAuctions[_index_auctions].title = _title;
            AllAuctions[_index_auctions].startPrice = _startPrice;
            AllAuctions[_index_auctions].description = _description;
            AllAuctions[_index_auctions].count = _count;
            AllAuctions[_index_auctions].commission = _commission;
            aucStates[_index_auctions] = State.Running;
            _index_auctions+=1;
            
            
        }
    function returnContentsAuctions(uint _index_auctions)public view returns(uint, string memory, uint, string memory, uint, uint){
        return (_index_auctions, AllAuctions[_index_auctions].title, AllAuctions[_index_auctions].startPrice, AllAuctions[_index_auctions].description, AllAuctions[_index_auctions].count, AllAuctions[_index_auctions].commission);
        
    }
    
    
    function returnTitleAuctions(uint _index_auctions)public view returns(string memory){
        return AllAuctions[_index_auctions].title;
        
    }
    function returnStrtPrcAuctions(uint _index_auctions)public view returns(uint){
        return AllAuctions[_index_auctions].startPrice;
        
    }
    function returnCountAuctions(uint _index_auctions)public view returns(uint){
        return AllAuctions[_index_auctions].count;
        
    }
    function returnCommissionAuctions(uint _index_auctions)public view returns(uint){
        return AllAuctions[_index_auctions].commission;
        
    }
    
    
    
    
    function getIndexAuctions()public view returns(uint){
        return _index_auctions;
    }
        
    
    
    
    modifier notOwner(){
        require(msg.sender != owner);
        _;
    }
    
    
    
    function setCountAdd(uint _id_auc, uint _count) public {
        AllAuctions[_id_auc].count = AllAuctions[_id_auc].count.add(_count);
        
    }
    
    function setCountSub(uint _id_auc, uint _count) public {
        AllAuctions[_id_auc].count = AllAuctions[_id_auc].count.sub(_count);
        
    }
    
    
    
    
    // buy goods
    function placeBid(uint _id_auctions, uint amt, address addr, string memory tmstp, uint id)  public notOwner returns(bool) {
        
        string memory ttl = returnTitleAuctions(_id_auctions);
        uint strtPrc = returnStrtPrcAuctions(_id_auctions);
        uint cnt = returnCountAuctions(_id_auctions);
        uint cnstPrc;
        cnstPrc = strtPrc;
        
        
        require(aucStates[_id_auctions] == State.Running);
        require(cnt>=amt);
       
              
        goods[_id_auctions][addr] = goods[_id_auctions][addr].add(amt);
        
        strtPrc = strtPrc.mul(100000000).mul(amt).add(commission.mul(1000000).mul(strtPrc).mul(amt));
        
        bids[_id_auctions][addr][id] = bids[_id_auctions][addr][id].add(strtPrc);
        
        bids_goods[_id_auctions][addr][id] = bids_goods[_id_auctions][addr][id].add(amt);
        
        trc20.approve(addr, address(this), strtPrc);
        
        // Move to tokens to contract address
        trc20.transferFrom(addr, address(this), strtPrc);
        
        setCountSub(_id_auctions, amt);

        setChecksOfGoods(addr, id, ttl, amt, cnstPrc, strtPrc.div(100000000), address(this), tmstp, false, "purchase");
        
        
        
        //startPrice=constPrice;
        
        return true;
}

    //confirm given good
     function finalizeAuction(uint _id_auctions, address _address, uint _index) payable public{
        string memory ttl = returnTitleAuctions(_id_auctions);
        uint strtPrc = returnStrtPrcAuctions(_id_auctions);
        uint cnt = returnCountAuctions(_id_auctions);
        uint cmsn = returnCommissionAuctions(_id_auctions);
        uint cnstPrc;
        cnstPrc = strtPrc;
         
        //the owner and bidders can finalize the auction.
        require(_address == owner || bids[_id_auctions][_address][_index] > 0);
        
        address payable recipiant;
        uint value;
        
        // owner can get highestPrice
        if(_address == owner){
            value = 0;
            
        }
    
        // Other bidders can get back the money 
        else {
            value =  bids[_id_auctions][_address][_index];
        }
        // initialize the value
        bids[_id_auctions][_address][_index] = 0;
        //recipiant.transfer(value);
        setNameOfGoodFromWallet(_address, _id_auctions);
        
        settWalletOfGoods(_address, _id_auctions, ttl, bids_goods[_id_auctions][_address][_index], cnstPrc, cmsn);
        
        trc20.approve(address(this), owner, value);
        
        trc20.transfer(owner, value);
        
        setIsConfirmGiven(_address, _index);
        
        if(cnt<=0){
            aucStates[_id_auctions] = State.Finalized;
        }
        
    }
    
    /*function cancelConfirm(address _address, uint _index) payable public{
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
        
        
    }*/
    
    
    
    
    
}



/*

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
    mapping(address => mapping(uint=>uint)) public bids_goods;
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
        trc20 = TRC20(address(0x411576d1a39ace4f0a24fc52b7a17be97904f6a2b8));
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
    function placeBid(uint amount, address _address, string memory _timestamp, uint _index)  public notOwner returns(bool) {
        require(auctionState == State.Running);
        require(count>=amount);
        
       
        //_index = ab.addIndex();       
        goods[_address] = goods[_address].add(amount);
        startPrice = startPrice.mul(100000000).mul(amount).add(commission.mul(1000000).mul(startPrice).mul(amount));
        
        bids[_address][_index] = bids[_address][_index].add(startPrice);
        bids_goods[_address][_index] = bids_goods[_address][_index].add(amount);
        
        trc20.approve(_address, address(this), startPrice);
        // Move to tokens to contract address
        trc20.transferFrom(_address, address(this), startPrice);
        count = count.sub(amount);
        //ab.settWalletOfGoods(_address, title, amount, constPrice, address(this), commisionConst);
        //ab.setNameOfGoodFromWallet(_address, title);
        ab.setChecksOfGoods(_address, _index, title, amount, constPrice, startPrice.div(100000000), address(this), _timestamp, false, "purchase");
        //ab.setIndexOfChecks(_address, _index);
        //ab.setIsConfirmGiven(_address, _index, address(this), false);
        
        
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
        ab.setNameOfGoodFromWallet(_address, title);
        ab.settWalletOfGoods(_address, title, bids_goods[_address][_index], constPrice, address(this), commisionConst);
        trc20.approve(address(this), owner, value);
        
        trc20.transfer(owner, value);
        ab.setIsConfirmGiven(_address, _index);
        if(count<=0){
            auctionState = State.Finalized;
        }
        
    }
    
    /*function cancelConfirm(address _address, uint _index) payable public{
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
        uint
        ) {
        return (
            title,
            startPrice,
            description,
            count,
            commission,
            uint(auctionState)
        );
    }
}

*/



