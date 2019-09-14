//TODO:
// handle overbooked situation

import ballerina/grpc;
import ballerina/io;
import ballerina/log;

listener grpc:Listener ep = new (9090);
// capacity of three tables at the same time
int count = 0;
json reservation = [];
json booking = [];
// should be sorted from greatest deposit to least
DepositDetails[] overbooks = [];
int bcount = 0;
string[3] tables = ["T1", "T2", "T3"];
string[] cantGet = [];
int cg = 0;// count cant get tables
int cd = 0;// count different dates
float MINIMUM_DEPOSIT_AMOUNT = 300;


function convertDuration(int d, int h, int m) returns (int, int) {
    int hour = d / 3600;
    int min = (d % 3600) / 60;
    hour = h + hour;
    if (hour > 24) {
        hour = hour - 24;
    }
    min = m + min;
    if (min > 59) {
        min = min - 60;
    }

    return (hour, min);
}

function isAvailable(BookingId bd) returns (boolean, string) {
    (int, int) time = convertDuration(bd.bd.duration, bd.bd.time.hour, bd.bd.time.min);

    string date = bd.bd.date.day + "-" + bd.bd.date.month + "-" + bd.bd.date.year;
    json b = {
        bookingId: bd.bookingId,
        fromTime: bd.bd.time.hour + ":" + bd.bd.time.min,
        toTime: time[0] + ":" + time[1],
        gotTable: "no"
    };

    if (booking.length() > 0) {
        foreach var item in 0 ... booking.length() - 1 {

            if (date.equalsIgnoreCase(booking[item].date.toString())) {
                cd = cd + 1;
                foreach var r in 0 ... booking[item].details.length() - 1 {
                    int | error endHour = int.convert(booking[item].details[r].toTime.toString().split(":")[0]);
                    int | error endMin = int.convert(booking[item].details[r].toTime.toString().split(":")[1]);

                    int | error startHour = int.convert(b.fromTime.toString().split(":")[0]);
                    int | error startMin = int.convert(b.fromTime.toString().split(":")[1]);

                    if (startHour is int && startMin is int && endHour is int && endMin is int) {
                        if (startHour < endHour || ((startHour == endHour) && startMin <= endMin)) {
                            cantGet[cg] = booking[item].details[r].gotTable.toString();
                            //io:println("table: ", booking[item].details[r].gotTable.toString());
                            cg = 1 + cg;
                        }
                    }
                }
                if (cg == 0) {
                    b.gotTable = "T1";                    // GIVE T1 BY DEFAULT
                    booking[item].details[booking[item].details.length()] = b;
                }
                else {
                    foreach var tb in 0 ... tables.length() - 1 {
                        int ct = 0;
                        foreach var nt in 0 ... cantGet.length() - 1 {
                            if (tables[tb].equalsIgnoreCase(cantGet[nt])) {
                                ct = 1 + ct;
                            }
                        }
                        if (ct == 0) {
                            b.gotTable = tables[tb];
                        }
                        ct = 0;
                    }
                    if (b.gotTable.toString().equalsIgnoreCase("no")) {
                        //io:println("Overbook situation....\n forward to deposit function please...");
                        // implement the deposit function
                        return (false, "");
                    }
                    else {
                        booking[item].details[booking[item].details.length()] = b;
                        //io:println("got this far");
                        return (true, b.gotTable.toString());
                    }
                }
                cg = 0;
                cantGet = [];
            }
        }

        if (cd == 0) {
            b.gotTable = "T1";            // T1 BY DEFAULT
            int l = booking.length();
            booking[booking.length()] = {
                date: date,
                details: [b]
            };
        }
        cd = 0;
        return (true, b.gotTable.toString());
    }
    else {
        booking[0] = {
            date: "",
            details: []
        };

        booking[0].date = date;
        b.gotTable = tables[0];
        booking[0].details[0] = b;
        bcount = bcount + 1;
        return (true, b.gotTable.toString());
    }



}
public function test(){
    io:println(booking);
}
public function sortOverbooks() {
    foreach int i in 0 ..< overbooks.length() {
        int j = i;
        while (j < overbooks.length()) {
            if (overbooks[j].depositAmount > overbooks[i].depositAmount) {
                // swap
                float c = overbooks[j].depositAmount;
                overbooks[j].depositAmount = overbooks[i].depositAmount;
                overbooks[i].depositAmount = c;
            }
            j += 1;
        }
    }
}
service kent on ep {

    resource function book(grpc:Caller caller, BookingDetails value) {
        // Implementation goes here.
        count = count + 1;
        BookingId bId = {
            bookingId: "b" + count,
            bd: value
        };
        error? result = ();
        map<any> b = {
            id: "b" + count,
            detail: bId.bd
        };
        json | error a =  json.convert(b);
        if (a is json) {
            reservation[count - 1] = a;
        }
        (boolean, string) available = isAvailable(bId);
        BookingResponse br = {
            bookingId: bId,
            conf: {
                confirmed: true
            },
            tableAssigned: ""
        };
        //io:println(available[1]);
        if (available[0] == false) {
            br.conf.confirmed = false;
        }
        io:println("Booking: ",booking);
        // You should return a BookingResponse
        result = caller->send(br);
        result = caller->complete();

    }

    resource function deposit(grpc:Caller caller, DepositDetails dd) {
        error? result;
        Confirmation c = {
            confirmed: false
        };
        
        // check deposit amount
        if (dd.depositAmount >= MINIMUM_DEPOSIT_AMOUNT) {
            json b = {};
            overbooks[overbooks.length()] = dd;
            c.confirmed = true;

            string id = dd.bookingId.bookingId;
            
            foreach var item in 0...reservation.length() - 1{
                if(reservation[item].id.toString().equalsIgnoreCase(id)){
                    b = reservation[item];
                }
            }

            (int, int) time = (0,0);
            int|error dr = int.convert(b.detail.duration);
            int|error h = int.convert(b.detail.time.hour);
            int|error m = int.convert(b.detail.time.min);
            if(dr is int && h is int && m is int){
                time = convertDuration(dr,h,m);
            }
            
            json d = {
                bookingId: b.id,
                fromTime: b.detail.time.hour.toString()+":"+b.detail.time.hour.toString(),
                toTime: time[0]+":"+time[1],
                gotTable: "DEPOSIT",
                depositAmount: dd.depositAmount
            };
            string date = b.detail.date.day.toString()+"-"+b.detail.date.month.toString()+"-"+b.detail.date.year.toString();
            boolean wasAssigned = false;
            foreach var item in 0...booking.length() - 1{
                if(booking[item].date.toString().equalsIgnoreCase(date)){
                    booking[item].details[booking[item].details.length()] = d;
                    wasAssigned = true;
                }
            }
            if(!wasAssigned){
                booking[booking.length()] = {
                    date: date,
                    details: [d]
                };
            }

        }
        io:println("Booking: ",booking);
        result = caller->send(c);
        result = caller->complete();
        sortOverbooks();
        
        //io:println("------------Deposit here---------------------------");
    }
}


// create a service that sends back the user info