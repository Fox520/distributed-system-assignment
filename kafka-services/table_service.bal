import wso2/kafka;
import ballerina/encoding;
import ballerina/io;


// recieve booking json via http


// Kafka consumer listener configurations
kafka:ConsumerConfig tableConfig = {
    bootstrapServers: "localhost:9092, localhost:9093",
    // Consumer group ID
    groupId: "tableSystem",
    topics: ["create-order", "leave-table", "request-bill", "do-payment", "request-menu"],
    pollingInterval: 1000
};

// fixed number of tables (remove this later, maybe)
map<json>[] tables = [
                    {"T1":{"state":"free", "guestReferenceNum":""}},
                    {"T2":{"state":"free", "guestReferenceNum":""}},
                    {"T3":{"state":"free", "guestReferenceNum":""}}];

// Create kafka listener
listener kafka:SimpleConsumer table_consumer = new(tableConfig);

service tableService on table_consumer{
    resource function onMessage(kafka:SimpleConsumer simpleConsumer, kafka:ConsumerRecord[] records) {
        foreach var entry in records {
            byte[] serializedMsg = entry.value;
            string msg = encoding:byteArrayToString(serializedMsg, encoding = "utf-8");
            io:println("Topic: "+entry.topic +"; Received Message: "+ msg);
            match(entry.topic){
                "create-order" => {
                    createOrder(msg);
                }
                "leave-table" => {
                    removeGuestsFromTable(msg);
                }
                "request-bill" => {
                    requestBill(msg);
                }
                "do-payment" => {
                    doPayment(msg);
                }
                "request-menu" => {
                    requestMenu(msg);
                }
            }
        }
    }
}

function createOrder(string msg){

}

function removeGuestsFromTable(string msg){

}

function requestBill(string msg){

}

function doPayment(string msg){

}

function requestMenu(string msg){

}

function getTableIndex(string str) returns int{
    match(str){
       "T1" => return 0;
       "T2" => return 1;
       "T3" => return 2;
       _ => return -1;
    }
}

function getTableNameFromIndex(int i) returns string{
    match(i){
       0 => return "T1";
       1 => return "T2";
       2 => return "T3";
       _ => return "";
    }
}