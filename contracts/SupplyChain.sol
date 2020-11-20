// SPDX-License-Identifier: MIT
/*
    This exercise has been updated to use Solidity version 0.6
    Breaking changes from 0.5 to 0.6 can be found here: 
    https://solidity.readthedocs.io/en/v0.6.12/060-breaking-changes.html
*/

pragma solidity >=0.6.0 <0.7.0;

contract SupplyChain {

  /* set owner - DONE */
  address public owner;

  /* Add a variable called skuCount to track the most recent sku # - DONE */
  uint public skuCount;

  /* Add a line that creates a public mapping that maps the SKU (a number) to an Item.
     Call this mappings items - DONE
  */
  mapping (uint => Item) public items;

  /* Add a line that creates an enum called State. This should have 4 states
    ForSale
    Sold
    Shipped
    Received
    (declaring them in this order is important for testing) - DONE
  */
  enum State {ForSale, Sold, Shipped, Received} 
  State state;

  /* Create a struct named Item.
    Here, add a name, sku, price, state, seller, and buyer
    We've left you to figure out what the appropriate types are,
    if you need help you can ask around :)
    Be sure to add "payable" to addresses that will be handling value transfer - DONE
  */
  struct Item {
    string  name;           // name of item
    uint    sku;            // stock keeping unit reference number
    uint    price;          // unit price
    State   state;          // (enum) state of sku
    address payable seller;
    address payable buyer;
  }

  /* Create 4 events with the same name as each possible State (see above)
    Prefix each event with "Log" for clarity, so the forSale event will be called "LogForSale"
    Each event should accept one argument, the sku - DONE */
//    event LogForSale(string indexed name, uint sku);  // here how would be my preferred events :-)
//    event LogSold(string indexed name, uint sku, address indexed buyer);
//    event LogShipped(string indexed name, uint sku, address indexed buyer);
//    event LogReceived(string indexed name, uint sku, address indexed buyer);
    event LogForSale (uint skuCount);    // events as specified in assignment
    event LogSold (uint sku);
    event LogShipped (uint sku);
    event LogReceived (uint sku);

/* Create a modifer that checks if the msg.sender is the owner of the contract - DONE */
    modifier isOwner { require(msg.sender == owner);_;}
    modifier verifyCaller (address _address) { require (msg.sender == _address); _;}
    modifier paidEnough (uint _price) { require(msg.value >= _price); _;}
    modifier checkValue (uint _sku) {
        //refund them after pay for item (why it is before, _ checks for logic before func)
        _;
        uint _price = items[_sku].price;
        uint amountToRefund = msg.value - _price;
        items[_sku].buyer.transfer(amountToRefund);
    }

  /* For each of the following modifiers, use what you learned about modifiers
   to give them functionality. For example, the forSale modifier should require
   that the item with the given sku has the state ForSale. 
   Note that the uninitialized Item.State is 0, which is also the index of the ForSale value,
   so checking that Item.State == ForSale is not sufficient to check that an Item is for sale.
   Hint: What item properties will be non-zero when an Item has been added?
   - Answer: see addItem(), it sets address of seller
   - DONE
   
   PS: Uncomment the modifier but keep the name for testing purposes! - DONE 
   */
  
  
    modifier forSale (uint _sku) { require (items[_sku].seller != address(0)); _;}
    modifier sold (uint _sku) { require (items[_sku].state == State.Sold); _;}
    modifier shipped (uint _sku) { require (items[_sku].state == State.Shipped); _;}
    modifier received (uint _sku) { require (items[_sku].state == State.Received); _;}


  constructor() public {
    /* Here, set the owner as the person who instantiated the contract
       and set your skuCount to 0. - DONE */
       owner = msg.sender;
       skuCount = 0;        // by default uint is set to 0, no?
  }

  function addItem(string memory _name, uint _price) public returns(bool){
    emit LogForSale(skuCount);
    items[skuCount] = Item({name: _name, sku: skuCount,
        price: _price, state: State.ForSale, seller: msg.sender, buyer: address(0)});
    skuCount = skuCount + 1;
    return true;
  }

  /* Add a keyword so the function can be paid (DONE). This function should transfer money
    to the seller (DONE), set the buyer as the person who called this transaction (DONE), and set the state
    to Sold (DONE). Be careful, this function should use 3 modifiers to check if the item is for sale (DONE),
    if the buyer paid enough (DONE), and check the value after the function is called to make sure the buyer is
    refunded any excess ether sent (DONE). Remember to call the event associated with this function! (DONE)*/
    function buyItem (uint sku)
    public payable forSale(sku) paidEnough(items[sku].price) checkValue (sku){
        items[sku].seller.transfer(items[sku].price);   // pay seller
        items[sku].buyer = msg.sender;                  // set buyer
        items[sku].state = State.Sold;                  // set state
        emit LogSold(sku);
    }

  /* Add 2 modifiers to check if the item is sold already (DONE), and that the person calling this function
    is the seller (DONE). Change the state of the item to shipped (DONE).
    Remember to call the event associated with this function! (DONE) */
    function shipItem (uint sku)
    public sold(sku) verifyCaller(items[sku].seller){
        items[sku].state = State.Shipped;
        emit LogShipped(sku);
    }

  /* Add 2 modifiers to check if the item is shipped already (DONE), and that the person calling this function
    is the buyer (DONE). Change the state of the item to received (DONE).
    Remember to call the event associated with this function! (DONE)*/
    function receiveItem(uint sku)
    public shipped(sku) verifyCaller(items[sku].buyer) {
        items[sku].state = State.Received;
        emit LogReceived(sku);
    }

  /* This function below is needed so we can run tests, just ignore it :) */
  
  function fetchItem(uint _sku) public view returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) {
    name = items[_sku].name;
    sku = items[_sku].sku;
    price = items[_sku].price;
    state = uint(items[_sku].state);
    seller = items[_sku].seller;
    buyer = items[_sku].buyer;
    return (name, sku, price, state, seller, buyer);
  } 

}
