import ballerina/grpc;
import ballerina/io;

listener grpc:Listener ep = new (9090);

int count = 0;

service kent on ep {

    resource function book(grpc:Caller caller, BookingDetails value) {
        // Implementation goes here.
        count = count + 1;
        io:println("value senrt: ",value);
        BookingId bId = {bookigId: "b"+count, bd: value}; 
        error? result =  ();

        // You should return a BookingId
        result = caller->send(bId);
        result = caller->complete();

    }
    resource function deposit(grpc:Caller caller, DepositDetails value) {
        // Implementation goes here.

        // You should return a Confirmation
    }
}

