// 1 - client service puslibshes the get-table message
// 2 - client service subscribes to the found-table

import wso2/kafka;
import ballerina/encoding;
import ballerina/io;

// client producer
kafka:ProducerConfig producerConfigs = {
    bootstrapServers: "localhost:9092",
    clientID: "client-producer",
    acks: "all",
    noRetries: 3
};
kafka:SimpleProducer kafkaProducer = new(producerConfigs);
// client consumer
kafka:ConsumerConfig consumerConfig = {
    bootstrapServers: "localhost:9092, localhost:9093",
    groupId: "client",
    topics: ["found-table"],
    pollingInterval: 1000
};
listener kafka:SimpleConsumer clientConsumer = new(consumerConfig);
service kafkaService on clientConsumer{
    resource function onMessage(kafka:SimpleConsumer simpleConsumer, kafka:ConsumerRecord[] records){
        foreach var entry in records {
            byte[] sMsg = entry.value;
            string msg = encoding:byteArrayToString(sMsg);
            io:println("Topic: ", entry.topic,"; Received Message: ",msg);
        }
    }
}


public function main(){
    clientGetTable();

}

function clientGetTable(){
    json bookingId = {"id":"b2"};
    byte[] sMsg = bookingId.toString().toByteArray("UTF-8");
    var publish = kafkaProducer->send(sMsg, "get-table", partition = 0);
}