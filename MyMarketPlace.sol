// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./MyToken.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyMarketPlace is ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;
    MyToken private token;
    mapping(uint256 => Order) private orders;
    Counters.Counter private orderCount;

    enum OrderStatus {
        CANCELLED,
        COMPLETED,
        OPEN
    }

    struct Order {
        address seller;
        address buyer;
        uint256 date;
        uint256 quantity;
        uint256 price;
        OrderStatus status;
    }

    struct ReturnedOrder {
        uint256 id;
        address seller;
        address buyer;
        uint256 date;
        uint256 quantity;
        uint256 price;
        OrderStatus status;
    }

    function setAddress(address tokenAddress) public onlyOwner {
        token = MyToken(tokenAddress);
    }

    function setOrder(
        uint256 timestamp,
        uint256 quantity,
        uint256 price
    ) public payable nonReentrant {
        require(
            token.getUserBalance(msg.sender) >= quantity,
            "Not enough token"
        );
        orders[orderCount.current()] = Order(
            msg.sender,
            address(0),
            timestamp,
            quantity,
            price,
            OrderStatus.OPEN
        );
        orderCount.increment();
        token.custTransfer(msg.sender, address(this), quantity);
    }

    function cancelOrder(uint256 id) public payable nonReentrant {
        require(msg.sender == orders[id].seller, "User not allowed");
        require(orders[id].status == OrderStatus.OPEN, "Status error");
        orders[id].status = OrderStatus.CANCELLED;
        token.custTransfer(
            address(this),
            orders[id].seller,
            orders[id].quantity
        );
    }

    function buyOrder(uint256 id) public payable nonReentrant {
        require(msg.value >= orders[id].price, "Not enough Matic sent");
        require(orders[id].status == OrderStatus.OPEN, "Status error");
        orders[id].status = OrderStatus.COMPLETED;
        orders[id].buyer = msg.sender;
        payable(orders[id].seller).transfer(msg.value);
        token.custTransfer(address(this), msg.sender, orders[id].quantity);
    }

    function listOrder() public view returns (ReturnedOrder[] memory) {
        ReturnedOrder[] memory returnedOrdersWithId = new ReturnedOrder[](
            orderCount.current()
        );
        for (uint256 i = 0; i < orderCount.current(); i++) {
            returnedOrdersWithId[i] = ReturnedOrder(
                i,
                orders[i].seller,
                orders[i].buyer,
                orders[i].date,
                orders[i].quantity,
                orders[i].price,
                orders[i].status
            );
        }
        return returnedOrdersWithId;
    }
}
