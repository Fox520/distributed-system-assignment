import ballerina/grpc;



service welcome on welcomeEP {

    resource function getTable(grpc:Caller caller, BookingId value) {
        // Implementation goes here.

        // You should return a Confirmation
    }
    resource function isSeated(grpc:Caller caller, BookingId value) {
        // Implementation goes here.

        // You should return a Confirmation
    }
}

