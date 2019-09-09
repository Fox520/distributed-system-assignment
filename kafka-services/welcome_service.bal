import wso2/kafka;
import ballerina/encoding;
import ballerina/io;

// Kafka consumer listener configurations
kafka:ConsumerConfig welcomeConfig = {
    bootstrapServers: "localhost:9092, localhost:9093",
    // Consumer group ID
    groupId: "arrival",
    topics: ["get-table"],
    pollingInterval: 1000
};

json[] waitingList = [];

// Create kafka listener
listener kafka:SimpleConsumer welcome_consumer = new(welcomeConfig);

service welcomeService on welcome_consumer{
    resource function onMessage(kafka:SimpleConsumer simpleConsumer, kafka:ConsumerRecord[] records) {
        foreach var entry in records {
            byte[] serializedMsg = entry.value;
            string msg = encoding:byteArrayToString(serializedMsg, encoding = "utf-8");
            io:println("Topic: "+entry.topic +"; Received Message: "+ msg);
            match(entry.topic){
                "get-table" => {
                    getTable(msg);
                }
            }
        }
    }
}

function getTable(string msg) {
    json msgJson = json.convert(msg);
    string referenceNumber = msgJson["refNum"].toString();
    boolean shouldJoinWaitingList = true;
    foreach int i in 0..<tables.length() {
        // check if table state is free
        // change state and assign guest to that table
        string tableName = getTableNameFromIndex(i);
        if(tables[i][tableName].state == "free"){
            tables[i][tableName].guestReferenceNum = referenceNumber;
            shouldJoinWaitingList = false;
        }
    }

    if(shouldJoinWaitingList){
        // add to waiting list
        waitingList[waitingList.length()] = msgJson;
    }
}

function sortWaitingList(){
    // sort according to time of deposit
}
