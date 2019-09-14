// 1 - client service puslibshes the get-table message
// 2 - client service subscribes to the found-table
// Note: Client should include a unique string along with msgs sent
//       since kafka will publish to all clients. Strring will be used to 
//       check if message is ours. (used in the background, not visible to client)
import wso2/kafka;
import ballerina/encoding;
import ballerina/io;
import ballerina/system;
import ballerina/log;

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
    topics: ["found-table", "get-menu", "order-delivery"],
    pollingInterval: 1000
};

string myUniqueMsgId = "";

listener kafka:SimpleConsumer clientConsumer = new(consumerConfig);
service kafkaService on clientConsumer{
    resource function onMessage(kafka:SimpleConsumer simpleConsumer, kafka:ConsumerRecord[] records){
        foreach var entry in records {
            io:println("Client Topic: ", entry.topic);
            byte[] sMsg = entry.value;
            string msg = encoding:byteArrayToString(sMsg);
            match(entry.topic){
                "found-table" => {
                    io:println("[FoundTableInfo] Received Message: ",msg);
                    io:StringReader sr = new (msg, encoding = "UTF-8");
                    json|error j =  sr.readJson();
                    if(j is json){
                        io:println(j);
                        if(j["unique_string"].toString() == myUniqueMsgId && j.Message != null){
                            io:println(j.Message); // follow me to table or here's your table
                            tableHandler();
                        }
                        else{
                            io:println("Communicate with table");
                            tableHandler(); // comment out maybe?
                        }
                    }else{
                        log:printError("FoundTableError", err=j);
                    }
                }
                "get-menu" => {
                    io:StringReader sr = new (msg, encoding = "UTF-8");
                    json|error j =  sr.readJson();
                    if(j is json){
                        if(j.unique_string == myUniqueMsgId){
                            // meant for us
                            io:println(j["the_menu"]);
                        }
                    }else{
                        log:printError("GetMenu Error", err = j);
                    }
                    tableHandler();
                }
                "order-delivery" => {
                    // waiter should send this
                    io:println("order");
                    io:println(msg);
                }
                _ => {
                    io:println("No handler found for topic: "+ entry.topic);
                }
            }
            
        }
    }
}


public function main(){
    myUniqueMsgId = system:uuid();
    clientGetTable();
    return;

}

function clientGetTable(){
    string bId = "b1";//io:readln("Enter your booking id please: ");
    // useful when getting table name
    string bDate = "12-2-2019";//io:readln("Enter your booking date please: ");
    if(bId != "" && bDate != ""){
        json msgOut = {"bid":bId, "unique_string":myUniqueMsgId, "booking_date": bDate};
        clientPublisher("get-table",msgOut.toString());
    }

}

function tableHandler(){
    io:println("Welcome to your table");
    // "create-order", "leave-table", "request-bill", "do-payment", "request-menu"
    io:println("1 - Menu\n2-Order\n3-request-bill\n4-pay\n5-Leave");
    boolean b = true;
    while(b){
        var option = io:readln("Option: ");
        match(option){
            "1" => {
                clientPublisher("request-menu",myUniqueMsgId);
            }
            "2" => {
                io:println("Order templete: itemName quantity, itemName quantity....");
                string orderMsg = io:readln("What will you order:\n");
                json msgOut = {"unique_id":myUniqueMsgId, "the_order": orderMsg};
                clientPublisher("create-order",msgOut.toString());
                io:println("Your order is being processed....");
            }
        }
    }
}

function clientPublisher(string topic, string msg){
    byte[] sMsg = msg.toByteArray("UTF-8");
    var publish = kafkaProducer->send(sMsg, topic, partition = 0);
}
