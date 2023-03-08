// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Astrashop{
    address public owner;
    struct Item {
        uint256 id;
        string name;
        string category;
        string image;
        uint256 cost;
        uint256 rating;
        uint256 stock;
    }

    struct Order{
        uint256 time;
        Item item;
    }
    mapping(uint256 => Item) public items;
    mapping(address=>uint) public orderCount;
    mapping(address=>mapping(uint=>Order)) public orders; 

    event Buy (address buyer, uint256 orderid, uint256 itemId);
    event List (string name, uint256  cost, uint256 quantity);

    modifier onlyOwner(){
        require(msg.sender==owner);
        _;
    }

    constructor(){
        owner = msg.sender;
    }

    // List Product
    function list(
        uint256 _id,
        string memory _name,
        string memory _category,
        string memory _image,
        uint256 _cost,
        uint256 _rating,
        uint256 _stock
    ) public onlyOwner{
        // Create Item suck
        Item memory item = Item(_id, _name, _category, _image, _cost, _rating, _stock);


        // Save Item struct to blockchain
        items[_id] =item;

        // Emit an Event
        emit List(_name, _cost, _stock);

    }

    // Buy Product 
    function buy(uint _id) public payable{
        // Fetch Item
        Item memory item =items[_id];
        
        //Require Enough ether to buy Item
        require(msg.value >= item.cost);

        //Require item is in the stock
        require(item.stock > 0);

        // Create  an order 
        Order memory order = Order(block.timestamp, item);

        // Add Order to User
        orderCount[msg.sender]++;  // <-- Order Id
        orders[msg.sender][orderCount[msg.sender]] = order;

        // Substract stock
        items[_id].stock = item.stock -1;

        // Emit Event
        emit Buy(msg.sender, orderCount[msg.sender], item.id);

    }

    // Withdrawl Fund
    function withdraw() public onlyOwner{
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success);
    }
}