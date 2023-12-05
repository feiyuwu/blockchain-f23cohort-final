// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract TicketSales {
    address public admin; // Admin address for managing the contract
    uint256 public ticketPrice; // Price of each ticket in wei

    enum TicketStatus { Unsold, Sold, Used }

    struct Ticket {
        string uniqname;
        TicketStatus status;
    }

    mapping(string => Ticket) private tickets;
    mapping(address => uint256) public balances; // Balances of ticket sellers

    event TicketPurchased(string indexed barcode, string uniqname, uint256 amountPaid);
    event TicketUsed(string indexed barcode, string uniqname);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    modifier ticketExists(string memory barcode) {
        require(bytes(tickets[barcode].uniqname).length > 0, "Ticket not found");
        _;
    }

    constructor(uint256 _ticketPrice) {
        admin = msg.sender;
        ticketPrice = _ticketPrice;
    }

    // Function to set or add a ticket
    function setTicket(string memory barcode, string memory uniqname) public onlyAdmin {
        require(bytes(tickets[barcode].uniqname).length == 0, "Ticket already exists");
        tickets[barcode] = Ticket(uniqname, TicketStatus.Unsold);
    }

    // Function to purchase a ticket
    function purchaseTicket(string memory barcode) public payable ticketExists(barcode) {
        require(tickets[barcode].status == TicketStatus.Unsold, "Ticket already sold or used");
        require(msg.value == ticketPrice, "Incorrect payment amount");

        balances[msg.sender] += msg.value;
        tickets[barcode].status = TicketStatus.Sold;

        emit TicketPurchased(barcode, tickets[barcode].uniqname, msg.value);
    }

    // Function to verify ticket seller authenticity
    function verifySeller(string memory barcode, string memory sellerUniqname) public view ticketExists(barcode) returns (string memory) {
        if (keccak256(bytes(tickets[barcode].uniqname)) == keccak256(bytes(sellerUniqname))) {
            return "Authentic Ticket Seller";
        } else {
            return "Not Authentic";
        }
    }

    // Function to use a ticket (mark it as used)
    function useTicket(string memory barcode) public ticketExists(barcode) {
        require(tickets[barcode].status == TicketStatus.Sold, "Ticket not sold or already used");
        require(keccak256(bytes(tickets[barcode].uniqname)) == keccak256(bytes(msg.sender)), "Not the ticket owner");

        tickets[barcode].status = TicketStatus.Used;

        emit TicketUsed(barcode, tickets[barcode].uniqname);
    }

    // Function to withdraw funds from the contract (only for the admin)
    function withdrawFunds() public onlyAdmin {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No funds available for withdrawal");

        balances[msg.sender] = 0;
        payable(msg.sender).transfer(balance);
    }
}
