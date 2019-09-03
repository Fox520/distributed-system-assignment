import ballerina/grpc;
import ballerina/io;

public function main (string... args) {
     tableClient ep = new("http://localhost:9090");

    tableBlockingClient blockingEp = new("http://localhost:9090");

}

service tableMessageListener = service {

    resource function onMessage(string message) {
        io:println("Response received from server: " + message);
    }

    resource function onError(error err) {
        io:println("Error from Connector: " + err.reason() + " - " + <string>err.detail().message);
    }

    resource function onComplete() {
        io:println("Server Complete Sending Responses.");
    }
};

