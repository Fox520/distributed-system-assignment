import wso2/kafka;
import ballerina/encoding;
import ballerina/io;
import ballerina/log;

kafka:ProducerConfig producerConfigsWaiter = {
    bootstrapServers: "localhost:9092",
    clientID: "waiter-producer",
    acks: "all",
    noRetries: 3
};

kafka:SimpleProducer kafkaProducerWaiter = new(producerConfigsWaiter);

// Kafka consumer listener configurations
kafka:ConsumerConfig waiterConfig = {
    bootstrapServers: "localhost:9092, localhost:9093",
    // Consumer group ID
    groupId: "serving",
    topics: ["take-delivery"],
    pollingInterval: 1000
};

// Create kafka listener
listener kafka:SimpleConsumer waiter_consumer = new(waiterConfig);

service waiterService on waiter_consumer{
    resource function onMessage(kafka:SimpleConsumer simpleConsumer, kafka:ConsumerRecord[] records) {
        foreach var entry in records {
            byte[] serializedMsg = entry.value;
            string msg = encoding:byteArrayToString(serializedMsg, encoding = "utf-8");
            io:println("Topic: "+entry.topic +"; Received Message: "+ msg);
            match(entry.topic){
                "take-delivery" => {
                    clientPublisherWaiter("order-delivery", msg);
                    log:printInfo("Sent order: "+msg);
                }
            }
        }
    }
}

function clientPublisherWaiter(string topic, string msg){
    byte[] sMsg = msg.toByteArray("UTF-8");
    var publish = kafkaProducerWaiter->send(sMsg, topic, partition = 0);
}
