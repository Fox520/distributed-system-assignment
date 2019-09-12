// welcom consume get-table
// welcome produces found-table
import wso2/kafka;
import ballerina/encoding;
import ballerina/io;

json booking = [];

// welcome consumer
kafka:ConsumerConfig consumerConfig = {
    bootstrapServers: "localhost:9092, localhost:9093",
    groupId: "welcome",
    topics: ["get-table"],
    pollingInterval: 1000
};

// welcome producer
kafka:ProducerConfig producerConfigs = {
    bootstrapServers: "localhost:9092",
    clientID: "welcome-producer",
    acks: "all",
    noRetries: 3
};
kafka:SimpleProducer kafkaProducer = new(producerConfigs);


public function foundTable(){
    json gotTable = {"confirmation": true};
    byte[] sMsg = gotTable.toString().toByteArray("UTF-8");

    var send = kafkaProducer->send(sMsg, "found-table", partition = 0);
}

// listener http:Listener htt = new(4000);
// @http
// service welcomeService on http:Listenter(4000){
//     resource function getData(http:Caller caller, http:Request req){
//         json|error rePayload = request.getJsonPayload();
//     }
// }

listener kafka:SimpleConsumer welcomeConsumer = new(consumerConfig);
service kafkaService on welcomeConsumer {
    resource function onMessage(kafka:SimpleConsumer simpleConsumer, kafka:ConsumerRecord[] records){
        foreach var entry in records {
            byte[] sMsg = entry.value;
            string msg = encoding:byteArrayToString(sMsg);
            // send a message follow me to the table
            io:println("Topic: ", entry.topic,"; Received Message");
            // find the table
            foundTable();
        }
    }


}