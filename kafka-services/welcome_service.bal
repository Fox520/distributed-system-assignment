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


public function foundTable(json data){
    json gotTable = data;
    byte[] sMsg = gotTable.toString().toByteArray("UTF-8");

    var send = kafkaProducer->send(sMsg, "found-table", partition = 0);
}

function getBaseType(string contentType) returns string {
    var result = mime:getMediaType(contentType);
    if (result is mime:MediaType) {
        return result.getBaseType();
    } else {
        panic result;
    }
}

listener kafka:SimpleConsumer welcomeConsumer = new(consumerConfig);
service kafkaServiceWelcome on welcomeConsumer {
    resource function onMessage(kafka:SimpleConsumer simpleConsumer, kafka:ConsumerRecord[] records){
        foreach var entry in records {
            byte[] sMsg = entry.value;
            json msg = encoding:byteArrayToString(sMsg);
            // send a message follow me to the table
            io:println("Topic: ", entry.topic,"; Received Message: ",msg);
            http:Client clientEp = new ("http://localhost:5000/getBooking");
            var res = clientEp->post("/getB",{bId: msg});
            json data = handleRequest(res);
            // find the table
            foundTable(data);
            

            
            

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