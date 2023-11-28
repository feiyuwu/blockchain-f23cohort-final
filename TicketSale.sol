// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23; 

contract TicketSales {
    // Mapping from barcode to uniqname
    mapping(string => string) private tickets;

    // Function to set or add a ticket
    function setTicket(string memory barcode, string memory uniqname) public {
        tickets[barcode] = uniqname;
    }

    // Function to verify ticket seller authenticity
    function verifySeller(string memory barcode, string memory sellerUniquename) public view returns (string memory) {
        require(bytes(tickets[barcode]).length > 0, "Ticket not found");
        if (keccak256(bytes(tickets[barcode])) == keccak256(bytes(sellerUniquename))) {
            return "Authentic Ticket Seller";
        } else {
            return "Not Authentic";
        }
    }
}
