// welcom consume get-table
// welcome produces found-table
import wso2/kafka;
import ballerina/encoding;
import ballerina/io;
import ballerina/http;
import ballerina/mime;
import ballerina/log;
json booking = [];

// welcome consumer
kafka:ConsumerConfig consumerConfigWelcome = {
    bootstrapServers: "localhost:9092, localhost:9093",
    groupId: "welcome",
    topics: ["get-table"],
    pollingInterval: 1000
};

// welcome producer
kafka:ProducerConfig producerConfigsWelcome = {
    bootstrapServers: "localhost:9092",
    clientID: "welcome-producer",
    acks: "all",
    noRetries: 3
};
kafka:SimpleProducer kafkaProducerWelcome = new(producerConfigsWelcome);
http:Client tableHTTPEP = new("http://localhost:9090/table-manager");

public function foundTable(json data, string uniq){
    json gotTable = {"the_data":data, "unique_string": uniq};
    byte[] sMsg = gotTable.toString().toByteArray("UTF-8");

    var send = kafkaProducerWelcome->send(sMsg, "found-table", partition = 0);
}

function getBaseType(string contentType) returns string {
    var result = mime:getMediaType(contentType);
    if (result is mime:MediaType) {
        return result.getBaseType();
    } else {
        panic result;
    }
}

listener kafka:SimpleConsumer welcomeConsumer = new(consumerConfigWelcome);
service kafkaServiceWelcome on welcomeConsumer {
    resource function onMessage(kafka:SimpleConsumer simpleConsumer, kafka:ConsumerRecord[] records){
        foreach var entry in records {
            http:Request res = new;
            byte[] sMsg = entry.value;
            json msg = encoding:byteArrayToString(sMsg);
            string bb = msg["bid"].toString();
            // send a message follow me to the table
            io:println("Topic: ", entry.topic,"; Received Message: ",msg);
            // get booking info from grpc service and publish to table or simply update the variable
            res.setJsonPayload({bId: bb}, contentType = "application/json");
            //send a request and check response 
            var response = tableHTTPEP->post("/getBooking", res);
            json data = handleRequest(response);
            // find the table
            foundTable(data, msg["unique_id"].toString());
            

        }
    }

}

public function handleRequest(http:Response|error res) returns json{
    if(res is http:Response){
        if (res.hasHeader("content-type")) {
            string baseType = getBaseType(res.getContentType());
            if (mime:APPLICATION_JSON == baseType) {
                var payload = res.getJsonPayload();
                if (payload is json) {
                    return payload;
                } else {
                    log:printError("Error in parsing json data", err = payload);
                }
            }                 
        }
    }
}