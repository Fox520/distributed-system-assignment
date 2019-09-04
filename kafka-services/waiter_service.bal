import wso2/kafka;
import ballerina/encoding;
import ballerina/io;

// Kafka consumer listener configurations
kafka:ConsumerConfig waiterConfig = {
    bootstrapServers: "localhost:9092, localhost:9093",
    // Consumer group ID
    groupId: "serving",
    topics: ["do-serve"],
    pollingInterval: 1000
};

// Create kafka listener
listener kafka:SimpleConsumer waiter_consumer = new(waiterConfig);

service waiterService on kitchen_consumer{
    resource function onMessage(kafka:SimpleConsumer simpleConsumer, kafka:ConsumerRecord[] records) {
        foreach var entry in records {
            byte[] serializedMsg = entry.value;
            string msg = encoding:byteArrayToString(serializedMsg, encoding = "utf-8");
            io:println("Topic: "+entry.topic +"; Received Message: "+ msg);
        }
    }
}