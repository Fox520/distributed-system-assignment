import ballerina/grpc;
import ballerina/io;

listener grpc:Listener ep = new (9090);


// capacity of three tables at the same time
int count = 0;
json reservation = [];
json booked = [];

public function isAvailable(BookingId bd){
    int i = bd.bd.duration;
    int j = 0;
    int hour = i / 3600;
    int min = (i % 3600) / 60;
    hour = bd.bd.time.hour + hour;
    if(hour > 24){
        hour = hour -24;
    }
    min = bd.bd.time.min + min;
    if(min > 59){
        min = min - 60;
    }

    json b = {
        id: bd.bookigId,
        onDate: bd.bd.date.day+"-"+bd.bd.date.month+"-"+bd.bd.date.year,
        fromTime: bd.bd.time.hour+":"+bd.bd.time.min,
        toTime: hour+":"+min        
    };
    io:println("SIze: ",booked.length());
    if(booked.length() > 0){
    foreach int item in 0...booked.length()-1{
            if(b.onDate.toString().equalsIgnoreCase(booked[item].onDate.toString())){

                int|error endHour = int.convert(booked[item].toTime.toString().split(":")[0]);
                int|error endMin = int.convert(booked[item].toTime.toString().split(":")[1]);

                int|error startHour = int.convert(b.fromTime.toString().split(":")[0]);
                int|error startMin = int.convert(b.fromTime.toString().split(":")[1]);
                // confirms if the time of the time of the next booking hasn't been taken yet
                if(endHour is int && endMin is int && startHour is int && startMin is int){
                    if((startHour == endHour && startMin > endMin) || startHour > endHour){
                        booked[j] = b;
                         j = j + 1;
                         io:println("We are!");
                    }
                    else{
                        io:println("We are overbooked");
                    }
                }

            }
    }
    }
    else{
        booked[0] = b;

    }


}

service kent on ep {

    resource function book(grpc:Caller caller, BookingDetails value) {
        // Implementation goes here.
        count = count + 1;
        BookingId bId = {bookigId: "b"+count, bd: value};
        isAvailable(bId); 
        error? result =  ();
        map<any> b = {
            "b"+count : bId.bd
        };
        json|error a =  json.convert(b);
        if( a is json){
            reservation[count-1] = a;
        }      
        
        // You should return a BookingId
        result = caller->send(bId);
        result = caller->complete();

    }
    resource function deposit(grpc:Caller caller, DepositDetails value) {
        // Implementation goes here.

        // You should return a Confirmation
    }
}
