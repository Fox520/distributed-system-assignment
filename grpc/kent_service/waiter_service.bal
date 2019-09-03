import ballerina/grpc;

service waiter on waiterEP {

    resource function caterOrder(grpc:Caller caller, OrderDetails value) {
        // Implementation goes here.

        // You should return a OrderResult
    }
}

