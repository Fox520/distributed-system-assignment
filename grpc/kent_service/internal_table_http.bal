import ballerina/http;
import ballerina/io;


@http:ServiceConfig {
    basePath: "/table-manager"
}
const string PWD = "my password";
service lectureService on new http:Listener(9092) {
    
    @http:ResourceConfig{
        path: "/getBooking",
        methods: ["POST"]
    }

    resource function getInfo(http:Caller caller, http:Request request) returns error? {
        http:Response res = new;
        json incomingJSON = check request.getJsonPayload();
        string pwd = check string.convert(incomingJSON["password"]);
        if(pwd == PWD){
            res.setJsonPayload(booking, contentType = "application/json");
            check caller -> respond(res);
        }else{
            res.setTextPayload("Unable to retrieve data", contentType = "text/plain");
            res.statusCode = 404;
            check caller -> respond(res);
        }
    }
}