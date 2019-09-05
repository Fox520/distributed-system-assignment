import ballerina/grpc;
import ballerina/io;


public function main (string... args) {
     kentClient ep = new("http://localhost:9090");

    kentBlockingClient blockingEp = new("http://localhost:9090");

    reservation(blockingEp, 12,2,2019,1,30,3);
    reservation(blockingEp, 12,2,2019,4,0,4);
    reservation(blockingEp, 12,2,2019,3,0,4);
    reservation(blockingEp, 12,2,2019,3,0,4);
    reservation(blockingEp, 12,2,2019,3,0,4);
    reservation(blockingEp, 12,2,2019,3,0,4);
    reservation(blockingEp, 11,5,2019,3,0,4);
   
}


public function reservation(kentBlockingClient ep, int day, int month, int year, int hour, int min, int guest, int duration = 7200){
    io:println("-----Booking------");   
    BookingDetails bd = {
        date: {day: day, month: month, year: year},
        time: {hour: hour, min: min},
        guest: guest,
        duration: duration
    };
    var res = ep->book(bd);
    if(res is error){
        io:println("Error: ",res.reason()," - ", res.detail().message,"\n\n");
    }
    else{
        BookingId bId;
        grpc:Headers resHeaders;
        (bId, resHeaders) = res;
        io:println("Response: ", bId ,"\n");
    }
}
