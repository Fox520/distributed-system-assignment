import ballerina/grpc;
import ballerina/io;

public function main (string... args) {
     kentClient ep = new("http://localhost:9090");

    kentBlockingClient blockingEp = new("http://localhost:9090");

    io:println("-----Booking------");
    // I have a date record with fields: day, month and year. But it is not accepting those fields it says that i have to use int_day int_month int_year
    // and using that the code does not work properlly
    // I officially hate ballerina
    Date d = {int_day: 1, int_month: 2, int_year: 3};
    BookingDetails bd = {
        date: d,
        time: {int_hour: 1, min: 2},
        guest: 3,
        duration: 3
    };

    var res = blockingEp->book(bd);

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

