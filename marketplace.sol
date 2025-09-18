 // SPDX-License-Identifier: MIT

//VERSION


pragma solidity ^0.8.26;
import "@openzeppelin/contracts@5.2.0/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract MarketPlace is ReentrancyGuard{

    address payable  public immutable feeAccount;
    //porcentaje a pagar por la creacion de cada NFT
    uint public immutable feeParcent;
    uint public itemCount;


    struct Item{

        uint itemID;
        IERC721 nft;
        uint tokenID;
        uint price;
        address payable seller;
        bool sold;


    }

    mapping (uint => Item) public items;
    //eventos
    event Bought(
        uint itemID,
        address indexed  nft,
        uint tokenID,
        uint price,
        address indexed  seller,
        address indexed buyer
    );

    event Offered(
        uint itemID,
        address indexed nft,
        uint tokenID,
        uint price,
        address indexed seller
    );



    constructor(uint _feePercent){
        feeAccount = payable (msg.sender);
        feeParcent =_feePercent;

    }


    function makeItem(IERC721 _nft, uint _tokenID, uint _price) external nonReentrant{

           require(_price > 0 ,"el precio debe ser mayor a 0");
           itemCount ++;
           _nft.transferFrom(msg.sender, address(this), _tokenID);
           items[itemCount]=Item(
                itemCount,
                _nft,
                _tokenID,
                _price,
                payable(msg.sender),
                false
           );

            emit Offered(
                itemCount, 
                address(_nft), 
                _tokenID, 
                _price, 
                payable(msg.sender)
            );

    }
        
    function purchaseItem(uint _itemID) external payable nonReentrant{
        uint _totalPrice = getTotalPrice(_itemID);
        Item storage item = items[_itemID];
        require(_itemID > 0 && _itemID <= itemCount , "No existe ese item");
        require(msg.value >= _totalPrice, "El valor enviado no es el correcto");
        require(!item.sold,"Este item esta vendido");
        item.seller.transfer(item.price);
        feeAccount.transfer(_totalPrice - item.price);
        item.sold = true;
        item.nft.transferFrom(address(this), msg.sender,item.tokenID);
        emit Bought(_itemID, address(item.nft), item.tokenID, items[_itemID].price, item.seller, msg.sender);


    }

    function getTotalPrice(uint _itemId) view public returns(uint){
        return ((items[_itemId].price + feeParcent));
    }



}

