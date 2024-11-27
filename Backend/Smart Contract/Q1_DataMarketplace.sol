// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

//import "@openzeppelin/contracts/utils/Strings.sol";

contract DataMarketplace {

    // A struct that holds the information of the seller's listing
    struct DataItem {
        address seller;
        string name; // item name
        string description; // about the item
        uint price; // Price in wei
        string licenseTerms; // e.g., "Non-commercial use only"
        uint salesCount; // Total sales 
    }

    // A struct that holds the information of a buyer's purchase
    struct BoughtItem {
        address buyer;
        string name;
        string description;
        string licenseTerms;
        uint price;
    }

    // Mapping of unique id => DataItem
    mapping(uint256 => DataItem) private items;

    // Array of listing ids
    uint256[] private ids;

    // Mapping of unique id => BoughtItem
    mapping(uint256 => BoughtItem) private inventory;

    // Mapping of sender address => unique id
    mapping(address => uint256[]) private property;

    // The total counts
    uint private dataItemCount;
    uint public listingsCount;
    uint public inventoryItemCount;

    // User's balance
    uint funds;

    // Triggered when a new data item is listed for sale
    event DataListed(uint256 dataId, address seller, 
    uint price, string licenseTerms);

    // Triggered when a data item has been purchased
    event DataPurchased(uint256 dataId, address buyer);

    // Triggered when a data item has been de-listed
    event DataRemoved(uint256 dataId, address seller);

    /// Checks if the buyer already owns an item
    error AlreadyPurchased();

    /// Checks if an item already exists
    error ItemAddedAlready();

    modifier ItemAddedAlreadyCheck(
        string memory _name, 
        string memory _description, 
        string memory _licenseTerms){
        //Checks if item exists
       if(items[hash(_name, _description, _licenseTerms)].price > 0)
            revert ItemAddedAlready();
        _; 
   }

    /*Constructor called at the beginning */
    constructor() payable {
        funds = msg.value; // assigns the user's funds
    }

    /*Generates unique id */
   function hash(string memory _name, 
   string memory _description, 
   string memory _licenseTerms)
   private pure returns (uint) {
        // Creates the unique id
        uint256 num = uint256(keccak256(abi.encodePacked(
            _name, 
            _description, 
            _licenseTerms)));
        // Extracts the first couple digits    
        uint256 first = num / 10 ** 70;
        // Runs until the id is six digits
        while (first > 10 ** 7){
            first = first / 10;
        }
        return first;
   }

    /*Write function that allows users to list data*/
    function listData(
        string memory _name,
        string memory _description,
        uint _price,
        string memory _licenseTerms
    ) external 
    ItemAddedAlreadyCheck(_name, _description, _licenseTerms)
    {
        // Checks price is non-zero
        require(_price > 0, "Price must be greater than zero");
        // Generates unique id
        uint256 _id = hash(_name, _description, _licenseTerms);
        // Pushes unique id into array
        ids.push(_id);
        // Creates item in items
        items[_id] = DataItem({
            seller: msg.sender,
            name: _name,
            description: _description,
            price: _price,
            licenseTerms: _licenseTerms,
            salesCount: 0
        });
        
        // Calls DataListed
        emit DataListed(listingsCount, msg.sender, _price, _licenseTerms);

        // Increment total counts
        dataItemCount++;
        listingsCount++;
    }

    /*Write function that delists items*/
    function delistData(uint256 _dataId) external {

        DataItem storage item = items[_dataId];

        // Checks if there is any listings
        require(listingsCount > 0, "There must be items already listed");
        //Checks if input is an existing item
        require(item.price > 0, "This is not an existing ID");
        // Checks if sender is seller
        require(msg.sender == item.seller, "Only the seller can delist their own item");
        
        //removes item from mapping
        delete items[_dataId];
        //removes id from array
        remove(_dataId);
        
        // Calls DataRemoved
        emit DataRemoved(_dataId, msg.sender);

        // Decrease listings
        listingsCount--;
    }

    /*Remove function called from deList function*/
    function remove(uint256 _dataId) internal {
        // Base case for id at front
        if(ids.length == 1){
            ids.pop();
            // Second case if id at end
        } else if (ids[ids.length - 1] == _dataId) {
            ids.pop();
        } else {
            // Loops through to find element
            for(uint i = 0; i < ids.length; i++){
                if(_dataId == ids[i]){
                    //shift elements down one
                    ids[i] = ids[ids.length - 1];
                    ids.pop();
                }
            }
        }
    }

    /*Write function that allows users to buy data items*/
    function buyData(uint256 _dataId, address _address) external payable {

        DataItem storage item = items[_dataId];

        // Checks if buyer is not the seller
        require(msg.sender != item.seller, "Cannot buy your own listing!");
        // Checks if buyer sends right amount of ETH
        require(msg.value == item.price, "Incorrect price sent");
        
        BoughtItem storage myItem = inventory[_dataId];
        // Checks if buyer already owns the data
        require(msg.sender != myItem.buyer, "You already have this data");

        // Adds item to inventory
        inventory[_dataId] = BoughtItem(
        _address, 
        item.name, 
        item.description, 
        item.licenseTerms, 
        item.price);

        // Adds id to property
        property[_address].push(_dataId);

        // Increments
        item.salesCount++;
        inventoryItemCount++;
        
        // Transfer funds to seller
        payable(item.seller).transfer(msg.value);

        // DataPurchased is called
        emit DataPurchased(_dataId, _address);

    }

    //function returnData(uint _dataId) external payable {
        //BoughtItem storage item = inventory[_dataId];
        //require(item.price > 0, "You do not own this item");
        //require(msg.sender == item.buyer, "You do are not the buyer");
    //}

    /*Getter for data details*/
    function getDataDetails(uint256 _dataId) public view returns (
        address seller,
        string memory name,
        string memory description,
        uint price,
        string memory licenseTerms,
        uint salesCount
    ) {
        // Checks if no items are listed
        require(listingsCount > 0, "There are no items listed");

        DataItem storage item = items[_dataId];
        // Checks if id does not exist
        require(item.price > 0, "This Item Id does not exist");

        return (
            item.seller,
            item.name,
            item.description,
            item.price,
            //string.concat(Strings.toString(item.price) , " Wei"),
            item.licenseTerms,
            item.salesCount
    ); 
    }

    /*Getter for personal inventory */
    function getInventoryItem(uint256 _dataId, address _address) public view returns(
        address buyer,
        string memory name,
        string memory description,  
        string memory licenseTerms
    ){
        BoughtItem storage item = inventory[_dataId];

        // Checks if inventory is empty
        require(inventoryItemCount > 0, "Inventory is empty");
        // Checks if item does not exist
        require(item.price > 0, "This item does not exist");
        // Check is the address is the buyer
        require(_address == item.buyer, "You do not own this item or your inventory is empty");

        return(
            _address,
            item.name,
            item.description,
            item.licenseTerms
            //item.returnDuration
        );
    }

    /*Getter function for item ids */
    function getItemIds() public view returns (uint256[] memory _ids) {
        return ids;
    }

    /*Getter function for personal inventory ids */
    function getInventoryIds(address _address) public view returns(uint256[] memory _ids){
        return property[_address];
    }



    

}