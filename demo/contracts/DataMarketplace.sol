// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract DataMarketplace {
    // In Solidity, a struct is a custom data type that 
    //allows you to group multiple variables of different types together under a single name. 
    struct DataItem {
        address seller;
        string name;
        string description;
        uint price; // Price in wei
        string licenseTerms; // e.g., "Non-commercial use only"
        bool isSold;
    }
    
    // Mapping to store data items by ID
    mapping(uint => DataItem) public dataItems;
    uint public dataItemCount;
    //This line defines a mapping called dataItems, which allows the contract to store 
    //multiple DataItem instances and retrieve each one by a unique identifier 
    //(an uint, which stands for unsigned integer).

    // Events to track important actions
    // Events can be useful for updating User interfaces, showing notifications, or generating reports of recent listings.

    // This event is triggered (or emitted) when a new data item is listed for sale on the marketplace. 
    // It logs the details of the listing, allowing anyone monitoring the blockchain to know that a new data item has been added.
    event DataListed(uint dataId, address seller, uint price, string licenseTerms);

    // This event is triggered when a data item is purchased. It logs the sale details, indicating that a transaction has occurred.
    event DataPurchased(uint dataId, address buyer);

    // Function to list data for sale
    function listData(
        string memory _name,
        string memory _description,
        uint _price,
        string memory _licenseTerms
        /// possibly we can do a membership as well with license terms
    ) public {
        require(_price > 0, "Price must be greater than zero");

        dataItems[dataItemCount] = DataItem({
            seller: msg.sender,
            name: _name,
            description: _description,
            price: _price,
            licenseTerms: _licenseTerms,
            isSold: false
        });
        
        emit DataListed(dataItemCount, msg.sender, _price, _licenseTerms);
        dataItemCount++;
    }

    // Function to buy data, transferring funds to the seller
    // the prototype assumed that we sell the data only once - need to modify for more than once
    function buyData(uint _dataId) public payable {
        DataItem storage item = dataItems[_dataId];
        
        require(msg.value == item.price, "Incorrect price sent");
        require(!item.isSold, "Data already sold");

        // Transfer funds to the seller
        // In Solidity, the payable keyword is used to indicate that an address can receive Ether.
        // Without this keyword, you cannot transfer Ether to an address.
        payable(item.seller).transfer(msg.value);
        item.isSold = true;

        emit DataPurchased(_dataId, msg.sender);
    }

    // Function to retrieve data details
    //  only retrieves metadata about the data item (like description, seller, price, and license terms), 
    // but not the actual data itself, use for some specific goal
    // qualification needs to be considered, qualified to view?
    function getDataDetails(uint _dataId) public view returns (
        address seller,
        string memory name,
        string memory description,
        uint price,
        string memory licenseTerms,
        bool isSold
    ) {
        DataItem storage item = dataItems[_dataId];
        return (
            item.seller,
            item.name,
            item.description,
            item.price,
            item.licenseTerms,
            item.isSold
        );
    }
}