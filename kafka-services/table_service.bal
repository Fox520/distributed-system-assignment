import wso2/kafka;
import ballerina/encoding;
import ballerina/io;

// Kafka consumer listener configurations
kafka:ConsumerConfig tableConfig = {
    bootstrapServers: "localhost:9092, localhost:9093",
    // Consumer group ID
    groupId: "tableSystem",
    topics: ["create-order", "add-guests", "leave-table", "request-bill", "do-payment", "request-menu"],
    pollingInterval: 1000
};

// Create kafka listener
listener kafka:SimpleConsumer table_consumer = new(tableConfig);

service tableService on table_consumer{
    resource function onMessage(kafka:SimpleConsumer simpleConsumer, kafka:ConsumerRecord[] records) {
        foreach var entry in records {
            byte[] serializedMsg = entry.value;
            string msg = encoding:byteArrayToString(serializedMsg, encoding = "utf-8");
            io:println("Topic: "+entry.topic +"; Received Message: "+ msg);
        }
    }
}