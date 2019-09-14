import wso2/kafka;
import ballerina/encoding;
import ballerina/io;

// this is used by all other producers within this directory
// how ballerina works ;) [except when you change variable names]
// kafka:ProducerConfig producerConfigs = {
//     bootstrapServers: "localhost:9092",
//     clientID: "basic-producer",
//     acks: "all",
//     noRetries: 3
// };

// kafka:SimpleProducer kafkaProducer = new(producerConfigs);

// Kafka consumer listener configurations
kafka:ConsumerConfig kitchenConfig = {
    bootstrapServers: "localhost:9092, localhost:9093",
    // Consumer group ID
    groupId: "kitchen-bar",
    topics: ["new-order"],
    pollingInterval: 1000
};

// Create kafka listener
listener kafka:SimpleConsumer kitchen_consumer = new(kitchenConfig);

map<json> shopItems = {
                    "coke" : 5.2,
                    "fanta": 5.1,
                    "food" : 9,
                    "bread": 8};

service kitchenBarService on kitchen_consumer{
    resource function onMessage(kafka:SimpleConsumer simpleConsumer, kafka:ConsumerRecord[] records) {
        foreach var entry in records {
            byte[] serializedMsg = entry.value;
            string msg = encoding:byteArrayToString(serializedMsg, encoding = "utf-8");
            io:println("Topic: "+entry.topic +"; Received Message: "+ msg);
            match (entry.topic){
                "new-order" => {
                    error? e = newOrder(msg);
                }
            }
        }
    }
}

function newOrder(string msg) returns (error?){
    // send back cost
    float totalCost = 0;
    json variable = json.convert(msg);
    // id needed so that it doesn't get used by wrong receiver...that's the though
    string identity = <string>variable["id"];
    json items = variable["items"];
    // loop through calculating the cost etc.
    foreach var kv in items {
        string itemName = kv[0];
        int quantity = <int>kv[1];
        float price = <float>shopItems[itemName];
        totalCost += totalCost + (quantity * price);
    }
    // send here | topic --> cost-of-order
    json returnMsg = {"id": identity, "cost": totalCost};
    sendMsg(returnMsg.toString(), "get-order-delivered");

}

function sendMsg(string msg, string theTopic){
    byte[] serializedMsg = msg.toByteArray("UTF-8");
    error? sendResult = kafkaProducer -> send(serializedMsg, theTopic, partition = 0);
    if(sendResult is error){
        io:println("error sending update");
        io:println(sendResult.detail());
        io:println(sendResult.reason());
    }else{
        io:println("success sending update");
    }
}