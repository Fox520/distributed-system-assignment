import ballerina/grpc;

listener grpc:Listener ep = new (9000);

service kent on ep {

    resource function book(grpc:Caller caller, BookingDetails value) {
        // Implementation goes here. ..

        // You should return a BookingId
    }
    resource function deposit(grpc:Caller caller, DepositDetails value) {
        // Implementation goes here.

        // You should return a Confirmation
    }
}

