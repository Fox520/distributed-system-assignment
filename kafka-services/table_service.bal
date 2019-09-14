import wso2/kafka;
import ballerina/encoding;
import ballerina/io;
import ballerina/log;


// reference Menu
string menu = "Coke - 5.2\nFood - 9";

// table producer
kafka:ProducerConfig producerConfigsTable = {
    bootstrapServers: "localhost:9092",
    clientID: "table-producer",
    acks: "all",
    noRetries: 3
};
kafka:SimpleProducer kafkaProducerTable = new(producerConfigsTable);

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
                    requestMenu();
                }
            }
        }
    }
}

function createOrder(string msg){
    io:StringReader sr = new (msg, encoding = "UTF-8");
    json|error j =  sr.readJson();
    if(j is json){
        string unique_str = j["unique_string"].toString();
        string the_order = j["the_order"].toString();
    }else{
        log:printError("CreateOrder Error", err = j);
    }
    io:println("What was ordered");
    // send to the kitchen service and then from kitchen send to the client

}

function removeGuestsFromTable(string msg){

}

function requestBill(string msg){

}

function doPayment(string msg){

}

function requestMenu(){
    clientPublisher("get-menu",menu);

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
