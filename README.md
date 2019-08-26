# Ballerina Assignment
First assignment for distributed systems programming using [Ballerina](https://ballerina.io/).
## Short overview
The task is to design a fully automated restaurant application, named **kent**. The system should be able to make bookings, server and handle payment. 

Kent consists of a client module and a server which is composed of multiple microservices. Note: communication is done using [gRPC](https://grpc.io/).

# Client
Client (guest) remotely invokes **book** function (returns unique reference number) passing the following:
* reservation date
* preferred time
* the number of guests
* expected duration (*default 2 hours*)

If the place is overbooked, reservation date is moved.

Upon booking, the remote **deposit** function is used for payment of booking. Returns confirmation code, whether deposit was accepted or not.

### Functions
*The remote functions mentioned above*
```
Function    : book

Description : Creates a reservation booking

Parameters  : reservation_date          - unix time stamp (?)
              pref_time                 - unix time stamp (?)
              num_guests                - int
              expected_duration         - int (time in seconds)

Return      : reference_number          - string
```
```
Function    : deposit

Description : Pay for the reservation

Parameters  : reference_number          - string
              payment_amount            - float

Return      : confirmation_code         - boolean
```

# Services
There are various services that handle guests.
### *Welcome service*
It receives a reference number and if there's an available table, the guests seat instanly. Otherwise, the guests join a waiting list sorted in the order of time the deposit was paid during booking.
### *Table service*
Receives guest information e.g. *reference number* and can interact with the guests. Possible actions from guest:
* order food/beverages
* request bill -> do payment