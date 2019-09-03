import ballerina/grpc;


service tableService on tableEP {

    resource function addGuests(grpc:Caller caller, BookingId value) {
        // Implementation goes here.

        // You should return a Confirmation
    }
    resource function leaveTable(grpc:Caller caller, BookingId value) {
        // Implementation goes here.

        // You should return a Confirmation
    }
    resource function requestMenu(grpc:Caller caller,  value) {
        // Implementation goes here.

        // You should return a TheMenu
    }
    resource function newOrder(grpc:Caller caller, OrderDetails value) {
        // Implementation goes here.

        // You should return a OrderResult
    }
}

