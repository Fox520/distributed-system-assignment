import ballerina/grpc;
import ballerina/io;
import ballerina/math;


public function main (string... args) returns(error?) {

    kentBlockingClient blockingEp = new("http://localhost:9090");

    any brr = reservation(blockingEp, 12,2,2019,1,30,3);
    any isConfirmed2 = reservation(blockingEp, 12,2,2019,4,0,4);
    any isConfirmed3 = reservation(blockingEp, 12,2,2019,3,0,4);
    any isConfirmed4 = reservation(blockingEp, 12,2,2019,3,0,4);
    any isConfirmed5 = reservation(blockingEp, 12,2,2019,3,0,4);
    any isConfirmed6 = reservation(blockingEp, 12,2,2019,3,0,4);
    any isConfirmed7 = reservation(blockingEp, 11,5,2019,3,0,4);

    secc(brr, blockingEp);
    secc(isConfirmed2, blockingEp);
    secc(isConfirmed3, blockingEp);
    secc(isConfirmed4, blockingEp);
    secc(isConfirmed5, blockingEp);
    secc(isConfirmed6, blockingEp);
    secc(isConfirmed7, blockingEp);
}

public function secc(any brr, kentBlockingClient ep){
    if(brr is BookingResponse){
        // overbooked, so secure spot with deposit
        
        // get money to deposit
        float da = <float>math:randomInRange(300, 500);
        Confirmation? | error? c = securePlace(ep, da, brr.bookingId);
        if(c is Confirmation){
            if(c.confirmed){
                io:println("Deposit successful");
                // what to do after? 🤷
            }else{
                io:println("Deposit amount ","{",da,"}" ," too low. Minimum is $300");
            }
        }else if (c is error){
            io:println("Error: ", c.reason(), " - ", c.detail().message, "\n\n");
        }
    }
}

# Description
#
# + ep - Network endpoint 
# + da - Deposit amount
# + bid - BookingId instance
# + return - Confirmation or error
public function securePlace(kentBlockingClient ep, float da, BookingId bid) returns (Confirmation?|error?){
    DepositDetails dd = {
        depositAmount: da,
        bookingId: bid
    };
    var res = ep -> deposit(dd);
    if(res is error){
        io:println("Error: ",res.reason()," - ", res.detail().message,"\n\n");
        return res;
    }
    else{
        Confirmation c;
        grpc:Headers resHeaders;
        (c, resHeaders) = res;
        io:println("Response: ", c ,"\n");
        return c;
    }
}

# Description
#
# + ep - Network endpoint
# + guest - the number of guests
# + duration - length of seating at table
# + return - BookingResponse under any type
public function reservation(kentBlockingClient ep, int day, int month, int year, int hour, int min, int guest, int duration = 7200) returns(any){
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
        return;
    }
    else{
        BookingResponse br;
        grpc:Headers resHeaders;
        (br, resHeaders) = res;
        io:println("Response: ", br ,"\n");
        return br;
    }
}
