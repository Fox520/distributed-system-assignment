import ballerina/http;
import ballerina/io;


@http:ServiceConfig {
    basePath: "/"
}
service internalService on new http:Listener(8080) {
    
    @http:ResourceConfig{
        path: "/getBooking",
        methods: ["POST"]
    }

    resource function getInfo(http:Caller caller, http:Request request) returns error? {
        http:Response res = new;
        json incomingJSON = check request.getJsonPayload();
        string pwd = check string.convert(incomingJSON["password"]);
        if(pwd == "my_password"){
            res.setJsonPayload(booking, contentType = "application/json");
            check caller -> respond(res);
        }else{
            res.setTextPayload("Unable to retrieve data", contentType = "text/plain");
            res.statusCode = 404;
            check caller -> respond(res);
        }
    }
}