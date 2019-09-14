// 1 - client service puslibshes the get-table message
// 2 - client service subscribes to the found-table
// Note: Client should include a unique string along with msgs sent
//       since kafka will publish to all clients. Strring will be used to 
//       check if message is ours. (used in the background, not visible to client)
import wso2/kafka;
import ballerina/encoding;
import ballerina/io;
import ballerina/system;

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
    topics: ["found-table", "get-menu"],
    pollingInterval: 1000
};

string myUniqueMsgId="";

listener kafka:SimpleConsumer clientConsumer = new(consumerConfig);
service kafkaService on clientConsumer{
    resource function onMessage(kafka:SimpleConsumer simpleConsumer, kafka:ConsumerRecord[] records){
        foreach var entry in records {
            byte[] sMsg = entry.value;
            string msg = encoding:byteArrayToString(sMsg);
            match(entry.topic){
                "found-table" => {
                    //io:println("Topic: ", entry.topic,"; Received Message: ",msg);
                    io:StringReader sr = new (msg, encoding = "UTF-8");
                    json|error j =  sr.readJson();
                    if(j is json){
                        if(j.Message != null && j.unique_string == myUniqueMsgId){
                            io:println(j.Message);
                            return;
                        }
                        else{
                            io:println("Communicate with table");
                            tableHandler();
                        }
                    }
                }
                "get-menu" => {
                    io:println("\n",msg,"\n");
                    tableHandler();
                }
                "order-delivery" => {
                    // waiter should send this
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
    string bId = io:readln("Enter your booking id please: ");
    if(bId != ""){
        string bookingId = bId;
        json msgOut = {"bid":bookingId, "unique_string":myUniqueMsgId};
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
