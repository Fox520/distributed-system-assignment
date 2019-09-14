import wso2/kafka;
import ballerina/encoding;
import ballerina/io;
import ballerina/log;


// reference Menu
//string menu = "Coke - 5.2\nFood - 9";
json menu = {"Coke":5.2, "Food":9};
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

// to store log of ordered by guests (if time allows)
map<json> ordersForGuests = {}; // bookId:totalCost
map<json> itemOrdersForGuests = {};
// fixed number of tables (remove this later, maybe)
map<json> tables = {"T1":"",
                    "T2":"",
                    "T3":""};

// Create kafka listener
listener kafka:SimpleConsumer table_consumer = new(tableConfig);

service tableService on table_consumer{
    resource function onMessage(kafka:SimpleConsumer simpleConsumer, kafka:ConsumerRecord[] records) returns error?{
        foreach var entry in records {
            byte[] serializedMsg = entry.value;
            string msg = encoding:byteArrayToString(serializedMsg, encoding = "utf-8");
            //io:println("Topic: "+entry.topic +"; Received Message: "+ msg);
            match(entry.topic){
                "create-order" => {
                    check createOrder(msg);
                }
                "leave-table" => {
                    removeGuestsFromTable(msg);
                }
                "request-bill" => {
                    check requestBill(msg);
                }
                "do-payment" => {
                    doPayment(msg);
                }
                "request-menu" => {
                    requestMenu(msg);
                }
                _ => {
                    io:println("No handler found for topic: "+ entry.topic);
                }
            }
        }
    }
}

function createOrder(string msg) returns error?{
    io:StringReader sr = new (msg, encoding = "UTF-8");
    json|error j =  sr.readJson();
    if(j is json){
        // io:println(j);
        string unique_str = j["unique_string"].toString();
        string the_order = j["the_order"].toString();
        string bkId = j["bId"].toString();
        // itemName quantity,[no-space]itemName quantity....
        // split comma; then split space
        float totalCost = 0;
        string[] itemsToOrder = the_order.split(",");
        foreach string itemAmount in itemsToOrder {
            string[] kv = itemAmount.split(" ");
            string itemName = kv[0];
            int itemQuantity = check int.convert(kv[1]);
            // one-liner 😎
            totalCost += check float.convert(menu[itemName]) * itemQuantity;
        }
        int|error currentValue = int.convert(ordersForGuests[bkId]);
        ordersForGuests[bkId] = (currentValue is int)?currentValue + totalCost: totalCost;
        string|error currentLog = string.convert(itemOrdersForGuests[bkId].toString());
        if(currentLog is string){
            if(currentLog == "null"){
                itemOrdersForGuests[bkId] = the_order;
                io:println("is null");
            }else{
                itemOrdersForGuests[bkId] = currentLog + ", "+the_order;
            }
        }
        json msgOut = {"total_cost": totalCost, "unique_string": unique_str};
        clientPublisherTable("take-delivery", msgOut.toString());
    }else{
        log:printError("CreateOrder Error", err = j);
    }
}

function removeGuestsFromTable(string msg){

}

function requestBill(string msg) returns error?{
    io:StringReader sr = new (msg, encoding = "UTF-8");
    json j =  check sr.readJson();
    json msgOut = {
                    "unique_string": j["unique_string"].toString(),
                    "totalCost": ordersForGuests[j["booking_id"].toString()].toString(),
                    "ordered_items": itemOrdersForGuests[j["booking_id"].toString()].toString()
                    };
    clientPublisherTable("get-bill", msgOut.toString());
    
}

function doPayment(string msg){
    // Note: helper function getCost
}

function requestMenu(string uniq){
    // TODO: modify display on client side
    json msgOut = {"unique_string": uniq, "the_menu": menu.toString()};
    clientPublisherTable("get-menu",msgOut.toString());

}

function getCost(string bkid) returns float{
    float|error theTotal = float.convert(ordersForGuests[bkid].toString());
    if(theTotal is float){
        return theTotal;
    }
    return 0;
}

function clientPublisherTable(string topic, string msg){
    byte[] sMsg = msg.toByteArray("UTF-8");
    var publish = kafkaProducerTable->send(sMsg, topic, partition = 0);
}
