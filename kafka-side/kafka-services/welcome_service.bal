// welcom consume get-table
// welcome produces found-table
import wso2/kafka;
import ballerina/encoding;
import ballerina/io;
import ballerina/http;
import ballerina/mime;
import ballerina/log;
json booking = [];

// welcome consumer
kafka:ConsumerConfig consumerConfigWelcome = {
    bootstrapServers: "localhost:9092, localhost:9093",
    groupId: "welcome",
    topics: ["get-table"],
    pollingInterval: 1000
};

// welcome producer
kafka:ProducerConfig producerConfigsWelcome = {
    bootstrapServers: "localhost:9092",
    clientID: "welcome-producer",
    acks: "all",
    noRetries: 3
};
kafka:SimpleProducer kafkaProducerWelcome = new(producerConfigsWelcome);
http:Client tableHTTPEP = new("http://localhost:8080/");

public function foundTable(string uniq, string tbl="") {
    string mg = (tbl == "") ? "didn't find your table" : "Follow me to table " + tbl;
    json gotTable = {
        "Message": mg,
        "unique_string": uniq,
        "table_name": tbl
    };
    byte[] sMsg = gotTable.toString().toByteArray("UTF-8");
    var send = kafkaProducerWelcome->send(sMsg, "found-table", partition = 0);
}

function getBaseType(string contentType) returns string {
    var result = mime:getMediaType(contentType);
    if (result is mime:MediaType) {
        return result.getBaseType();
    } else {
        panic result;
    }
}

listener kafka:SimpleConsumer welcomeConsumer = new(consumerConfigWelcome);
service kafkaServiceWelcome on welcomeConsumer {
    resource function onMessage(kafka:SimpleConsumer simpleConsumer, kafka:ConsumerRecord[] records) returns error? {
        foreach var entry in records {
            http:Request res = new;
            byte[] sMsg = entry.value;
            string msgStr = encoding:byteArrayToString(sMsg);
            io:StringReader sr = new (msgStr, encoding = "UTF-8");
            json msg = check sr.readJson();
            // send a message follow me to the table
            //io:println("Topic: ", entry.topic,"; Received Message: ",msg["bid"],", ", msg["booking_date"]);
            string booking_date = msg["booking_date"].toString();
            string supplied_booking_id = msg["bid"].toString();
            // get booking info from grpc service and publish to table or simply update the variable
            // password to protect access to data from unauthorised actors
            res.setJsonPayload({
                "password": "my_password"
            }, contentType = "application/json");
            //send a request and check response

            http:Response response = checkpanic tableHTTPEP->post("/getBooking", res);
            json data = checkpanic response.getJsonPayload();
            boolean hasFound = false;
            foreach var item in <json[]>data {
                if (item["date"].toString() == booking_date) {
                    // find table from the details
                    foreach var dts in <json[]>item["details"] {
                        if (dts["bookingId"].toString() == supplied_booking_id) {
                            string assignedTable = dts["gotTable"].toString();
                            // set guest info to assigned table
                            tables[assignedTable] = supplied_booking_id;
                            foundTable(msg["unique_string"].toString(), tbl = assignedTable);
                            io:println("INFO: ", tables);
                            hasFound = true;
                        }
                    }
                } else {
                    io:println(item["date"].toString() + "  != supplied " + booking_date);
                }
            }
            // if got here, likely means above resulted in table not being found
            if (hasFound == false) {
                foundTable(msg["unique_string"].toString());
            }
        }
    }

}
//[{"date":"12-2-2019", "details":[{"bookingId":"b1", "fromTime":"1:30", "toTime":"3:30", "gotTable":"T1"}]}]


public function handleRequest(http:Response | error res) returns json {
    if (res is http:Response) {
        if (res.hasHeader("content-type")) {
            string baseType = getBaseType(res.getContentType());
            if (mime:APPLICATION_JSON == baseType) {
                var payload = res.getJsonPayload();
                if (payload is json) {
                    return payload;
                } else {
                    log:printError("Error in parsing json data", err = payload);
                }
            }
        }
    }
}
