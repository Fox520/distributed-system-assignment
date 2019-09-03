import ballerina/grpc;
import ballerina/io;

public type kentBlockingClient client object {
    private grpc:Client grpcClient;

    function __init(string url, grpc:ClientEndpointConfig? config = ()) {
        // initialize client endpoint.
        grpc:Client c = new(url, config = config);
        error? result = c.initStub("blocking", ROOT_DESCRIPTOR, getDescriptorMap());
        if (result is error) {
            panic result;
        } else {
            self.grpcClient = c;
        }
    }


    remote function book(BookingDetails req, grpc:Headers? headers = ()) returns ((BookingId, grpc:Headers)|error) {
        
        var payload = check self.grpcClient->blockingExecute("grpc_service.kent/book", req, headers = headers);
        grpc:Headers resHeaders = new;
        any result = ();
        (result, resHeaders) = payload;
        var value = BookingId.convert(result);
        if (value is BookingId) {
            return (value, resHeaders);
        } else {
            error err = error("{ballerina/grpc}INTERNAL", {"message": value.reason()});
            return err;
        }
    }

    remote function deposit(DepositDetails req, grpc:Headers? headers = ()) returns ((Confirmation, grpc:Headers)|error) {
        
        var payload = check self.grpcClient->blockingExecute("grpc_service.kent/deposit", req, headers = headers);
        grpc:Headers resHeaders = new;
        any result = ();
        (result, resHeaders) = payload;
        var value = Confirmation.convert(result);
        if (value is Confirmation) {
            return (value, resHeaders);
        } else {
            error err = error("{ballerina/grpc}INTERNAL", {"message": value.reason()});
            return err;
        }
    }

};

public type kentClient client object {
    private grpc:Client grpcClient;

    function __init(string url, grpc:ClientEndpointConfig? config = ()) {
        // initialize client endpoint.
        grpc:Client c = new(url, config = config);
        error? result = c.initStub("non-blocking", ROOT_DESCRIPTOR, getDescriptorMap());
        if (result is error) {
            panic result;
        } else {
            self.grpcClient = c;
        }
    }


    remote function book(BookingDetails req, service msgListener, grpc:Headers? headers = ()) returns (error?) {
        
        return self.grpcClient->nonBlockingExecute("grpc_service.kent/book", req, msgListener, headers = headers);
    }

    remote function deposit(DepositDetails req, service msgListener, grpc:Headers? headers = ()) returns (error?) {
        
        return self.grpcClient->nonBlockingExecute("grpc_service.kent/deposit", req, msgListener, headers = headers);
    }

};

public type welcomeBlockingClient client object {
    private grpc:Client grpcClient;

    function __init(string url, grpc:ClientEndpointConfig? config = ()) {
        // initialize client endpoint.
        grpc:Client c = new(url, config = config);
        error? result = c.initStub("blocking", ROOT_DESCRIPTOR, getDescriptorMap());
        if (result is error) {
            panic result;
        } else {
            self.grpcClient = c;
        }
    }


    remote function getTable(BookingId req, grpc:Headers? headers = ()) returns ((Confirmation, grpc:Headers)|error) {
        
        var payload = check self.grpcClient->blockingExecute("grpc_service.welcome/getTable", req, headers = headers);
        grpc:Headers resHeaders = new;
        any result = ();
        (result, resHeaders) = payload;
        var value = Confirmation.convert(result);
        if (value is Confirmation) {
            return (value, resHeaders);
        } else {
            error err = error("{ballerina/grpc}INTERNAL", {"message": value.reason()});
            return err;
        }
    }

    remote function isSeated(BookingId req, grpc:Headers? headers = ()) returns ((Confirmation, grpc:Headers)|error) {
        
        var payload = check self.grpcClient->blockingExecute("grpc_service.welcome/isSeated", req, headers = headers);
        grpc:Headers resHeaders = new;
        any result = ();
        (result, resHeaders) = payload;
        var value = Confirmation.convert(result);
        if (value is Confirmation) {
            return (value, resHeaders);
        } else {
            error err = error("{ballerina/grpc}INTERNAL", {"message": value.reason()});
            return err;
        }
    }

};

public type welcomeClient client object {
    private grpc:Client grpcClient;

    function __init(string url, grpc:ClientEndpointConfig? config = ()) {
        // initialize client endpoint.
        grpc:Client c = new(url, config = config);
        error? result = c.initStub("non-blocking", ROOT_DESCRIPTOR, getDescriptorMap());
        if (result is error) {
            panic result;
        } else {
            self.grpcClient = c;
        }
    }


    remote function getTable(BookingId req, service msgListener, grpc:Headers? headers = ()) returns (error?) {
        
        return self.grpcClient->nonBlockingExecute("grpc_service.welcome/getTable", req, msgListener, headers = headers);
    }

    remote function isSeated(BookingId req, service msgListener, grpc:Headers? headers = ()) returns (error?) {
        
        return self.grpcClient->nonBlockingExecute("grpc_service.welcome/isSeated", req, msgListener, headers = headers);
    }

};

public type tableBlockingClient client object {
    private grpc:Client grpcClient;

    function __init(string url, grpc:ClientEndpointConfig? config = ()) {
        // initialize client endpoint.
        grpc:Client c = new(url, config = config);
        error? result = c.initStub("blocking", ROOT_DESCRIPTOR, getDescriptorMap());
        if (result is error) {
            panic result;
        } else {
            self.grpcClient = c;
        }
    }


    remote function addGuests(BookingId req, grpc:Headers? headers = ()) returns ((Confirmation, grpc:Headers)|error) {
        
        var payload = check self.grpcClient->blockingExecute("grpc_service.table/addGuests", req, headers = headers);
        grpc:Headers resHeaders = new;
        any result = ();
        (result, resHeaders) = payload;
        var value = Confirmation.convert(result);
        if (value is Confirmation) {
            return (value, resHeaders);
        } else {
            error err = error("{ballerina/grpc}INTERNAL", {"message": value.reason()});
            return err;
        }
    }

    remote function leaveTable(BookingId req, grpc:Headers? headers = ()) returns ((Confirmation, grpc:Headers)|error) {
        
        var payload = check self.grpcClient->blockingExecute("grpc_service.table/leaveTable", req, headers = headers);
        grpc:Headers resHeaders = new;
        any result = ();
        (result, resHeaders) = payload;
        var value = Confirmation.convert(result);
        if (value is Confirmation) {
            return (value, resHeaders);
        } else {
            error err = error("{ballerina/grpc}INTERNAL", {"message": value.reason()});
            return err;
        }
    }

    remote function requestMenu(grpc:Headers? headers = ()) returns ((TheMenu, grpc:Headers)|error) {
        Empty req = {};
        var payload = check self.grpcClient->blockingExecute("grpc_service.table/requestMenu", req, headers = headers);
        grpc:Headers resHeaders = new;
        any result = ();
        (result, resHeaders) = payload;
        var value = TheMenu.convert(result);
        if (value is TheMenu) {
            return (value, resHeaders);
        } else {
            error err = error("{ballerina/grpc}INTERNAL", {"message": value.reason()});
            return err;
        }
    }

    remote function newOrder(OrderDetails req, grpc:Headers? headers = ()) returns ((OrderResult, grpc:Headers)|error) {
        
        var payload = check self.grpcClient->blockingExecute("grpc_service.table/newOrder", req, headers = headers);
        grpc:Headers resHeaders = new;
        any result = ();
        (result, resHeaders) = payload;
        var value = OrderResult.convert(result);
        if (value is OrderResult) {
            return (value, resHeaders);
        } else {
            error err = error("{ballerina/grpc}INTERNAL", {"message": value.reason()});
            return err;
        }
    }

};

public type tableClient client object {
    private grpc:Client grpcClient;

    function __init(string url, grpc:ClientEndpointConfig? config = ()) {
        // initialize client endpoint.
        grpc:Client c = new(url, config = config);
        error? result = c.initStub("non-blocking", ROOT_DESCRIPTOR, getDescriptorMap());
        if (result is error) {
            panic result;
        } else {
            self.grpcClient = c;
        }
    }


    remote function addGuests(BookingId req, service msgListener, grpc:Headers? headers = ()) returns (error?) {
        
        return self.grpcClient->nonBlockingExecute("grpc_service.table/addGuests", req, msgListener, headers = headers);
    }

    remote function leaveTable(BookingId req, service msgListener, grpc:Headers? headers = ()) returns (error?) {
        
        return self.grpcClient->nonBlockingExecute("grpc_service.table/leaveTable", req, msgListener, headers = headers);
    }

    remote function requestMenu(service msgListener, grpc:Headers? headers = ()) returns (error?) {
        Empty req = {};
        return self.grpcClient->nonBlockingExecute("grpc_service.table/requestMenu", req, msgListener, headers = headers);
    }

    remote function newOrder(OrderDetails req, service msgListener, grpc:Headers? headers = ()) returns (error?) {
        
        return self.grpcClient->nonBlockingExecute("grpc_service.table/newOrder", req, msgListener, headers = headers);
    }

};

public type waiterBlockingClient client object {
    private grpc:Client grpcClient;

    function __init(string url, grpc:ClientEndpointConfig? config = ()) {
        // initialize client endpoint.
        grpc:Client c = new(url, config = config);
        error? result = c.initStub("blocking", ROOT_DESCRIPTOR, getDescriptorMap());
        if (result is error) {
            panic result;
        } else {
            self.grpcClient = c;
        }
    }


    remote function caterOrder(OrderDetails req, grpc:Headers? headers = ()) returns ((OrderResult, grpc:Headers)|error) {
        
        var payload = check self.grpcClient->blockingExecute("grpc_service.waiter/caterOrder", req, headers = headers);
        grpc:Headers resHeaders = new;
        any result = ();
        (result, resHeaders) = payload;
        var value = OrderResult.convert(result);
        if (value is OrderResult) {
            return (value, resHeaders);
        } else {
            error err = error("{ballerina/grpc}INTERNAL", {"message": value.reason()});
            return err;
        }
    }

};

public type waiterClient client object {
    private grpc:Client grpcClient;

    function __init(string url, grpc:ClientEndpointConfig? config = ()) {
        // initialize client endpoint.
        grpc:Client c = new(url, config = config);
        error? result = c.initStub("non-blocking", ROOT_DESCRIPTOR, getDescriptorMap());
        if (result is error) {
            panic result;
        } else {
            self.grpcClient = c;
        }
    }


    remote function caterOrder(OrderDetails req, service msgListener, grpc:Headers? headers = ()) returns (error?) {
        
        return self.grpcClient->nonBlockingExecute("grpc_service.waiter/caterOrder", req, msgListener, headers = headers);
    }

};

type Empty record {|
    
|};


type Date record {|
    int int_day;
    int int_month;
    int int_year;
    
|};


type Time record {|
    int int_hour;
    int min;
    
|};


type BookingDetails record {|
    Date date;
    Time time;
    int guests;
    int duration;
    
|};


type BookingId record {|
    string reference_id;
    BookingDetails bd;
    
|};


type DepositDetails record {|
    BookingId id;
    float money;
    
|};


type Confirmation record {|
    boolean confirmed;
    
|};


type OrderResult record {|
    float total;
    
|};


type OrderDetails record {|
    string orderInfo;
    
|};


type TheMenu record {|
    string menu;
    
|};


type TableDetails record {|
    BookingId bi;
    BookingDetails bd;
    
|};



const string ROOT_DESCRIPTOR = "0A0F677270635F6B656E742E70726F746F120C677270635F736572766963651A1B676F6F676C652F70726F746F6275662F656D7074792E70726F746F22420A044461746512100A03646179180120012805520364617912140A056D6F6E746818022001280552056D6F6E746812120A0479656172180320012805520479656172222C0A0454696D6512120A04686F75721801200128055204686F757212100A036D696E18022001280552036D696E2294010A0E426F6F6B696E6744657461696C7312260A046461746518012001280B32122E677270635F736572766963652E4461746552046461746512260A0474696D6518022001280B32122E677270635F736572766963652E54696D65520474696D6512160A066775657374731803200128055206677565737473121A0A086475726174696F6E18042001280552086475726174696F6E225C0A09426F6F6B696E67496412210A0C7265666572656E63655F6964180120012809520B7265666572656E63654964122C0A02626418022001280B321C2E677270635F736572766963652E426F6F6B696E6744657461696C7352026264224F0A0E4465706F73697444657461696C7312270A02696418012001280B32172E677270635F736572766963652E426F6F6B696E6749645202696412140A056D6F6E657918022001280252056D6F6E6579222C0A0C436F6E6669726D6174696F6E121C0A09636F6E6669726D65641801200128085209636F6E6669726D656422230A0B4F72646572526573756C7412140A05746F74616C1801200128025205746F74616C222C0A0C4F7264657244657461696C73121C0A096F72646572496E666F18012001280952096F72646572496E666F221D0A075468654D656E7512120A046D656E7518012001280952046D656E7522650A0C5461626C6544657461696C7312270A02626918012001280B32172E677270635F736572766963652E426F6F6B696E67496452026269122C0A02626418022001280B321C2E677270635F736572766963652E426F6F6B696E6744657461696C7352026264328A010A046B656E74123D0A04626F6F6B121C2E677270635F736572766963652E426F6F6B696E6744657461696C731A172E677270635F736572766963652E426F6F6B696E67496412430A076465706F736974121C2E677270635F736572766963652E4465706F73697444657461696C731A1A2E677270635F736572766963652E436F6E6669726D6174696F6E328B010A0777656C636F6D65123F0A086765745461626C6512172E677270635F736572766963652E426F6F6B696E6749641A1A2E677270635F736572766963652E436F6E6669726D6174696F6E123F0A08697353656174656412172E677270635F736572766963652E426F6F6B696E6749641A1A2E677270635F736572766963652E436F6E6669726D6174696F6E328D020A057461626C6512400A0961646447756573747312172E677270635F736572766963652E426F6F6B696E6749641A1A2E677270635F736572766963652E436F6E6669726D6174696F6E12410A0A6C656176655461626C6512172E677270635F736572766963652E426F6F6B696E6749641A1A2E677270635F736572766963652E436F6E6669726D6174696F6E123C0A0B726571756573744D656E7512162E676F6F676C652E70726F746F6275662E456D7074791A152E677270635F736572766963652E5468654D656E7512410A086E65774F72646572121A2E677270635F736572766963652E4F7264657244657461696C731A192E677270635F736572766963652E4F72646572526573756C74324D0A0677616974657212430A0A63617465724F72646572121A2E677270635F736572766963652E4F7264657244657461696C731A192E677270635F736572766963652E4F72646572526573756C74620670726F746F33";
function getDescriptorMap() returns map<string> {
    return {
        "grpc_kent.proto":"0A0F677270635F6B656E742E70726F746F120C677270635F736572766963651A1B676F6F676C652F70726F746F6275662F656D7074792E70726F746F22420A044461746512100A03646179180120012805520364617912140A056D6F6E746818022001280552056D6F6E746812120A0479656172180320012805520479656172222C0A0454696D6512120A04686F75721801200128055204686F757212100A036D696E18022001280552036D696E2294010A0E426F6F6B696E6744657461696C7312260A046461746518012001280B32122E677270635F736572766963652E4461746552046461746512260A0474696D6518022001280B32122E677270635F736572766963652E54696D65520474696D6512160A066775657374731803200128055206677565737473121A0A086475726174696F6E18042001280552086475726174696F6E225C0A09426F6F6B696E67496412210A0C7265666572656E63655F6964180120012809520B7265666572656E63654964122C0A02626418022001280B321C2E677270635F736572766963652E426F6F6B696E6744657461696C7352026264224F0A0E4465706F73697444657461696C7312270A02696418012001280B32172E677270635F736572766963652E426F6F6B696E6749645202696412140A056D6F6E657918022001280252056D6F6E6579222C0A0C436F6E6669726D6174696F6E121C0A09636F6E6669726D65641801200128085209636F6E6669726D656422230A0B4F72646572526573756C7412140A05746F74616C1801200128025205746F74616C222C0A0C4F7264657244657461696C73121C0A096F72646572496E666F18012001280952096F72646572496E666F221D0A075468654D656E7512120A046D656E7518012001280952046D656E7522650A0C5461626C6544657461696C7312270A02626918012001280B32172E677270635F736572766963652E426F6F6B696E67496452026269122C0A02626418022001280B321C2E677270635F736572766963652E426F6F6B696E6744657461696C7352026264328A010A046B656E74123D0A04626F6F6B121C2E677270635F736572766963652E426F6F6B696E6744657461696C731A172E677270635F736572766963652E426F6F6B696E67496412430A076465706F736974121C2E677270635F736572766963652E4465706F73697444657461696C731A1A2E677270635F736572766963652E436F6E6669726D6174696F6E328B010A0777656C636F6D65123F0A086765745461626C6512172E677270635F736572766963652E426F6F6B696E6749641A1A2E677270635F736572766963652E436F6E6669726D6174696F6E123F0A08697353656174656412172E677270635F736572766963652E426F6F6B696E6749641A1A2E677270635F736572766963652E436F6E6669726D6174696F6E328D020A057461626C6512400A0961646447756573747312172E677270635F736572766963652E426F6F6B696E6749641A1A2E677270635F736572766963652E436F6E6669726D6174696F6E12410A0A6C656176655461626C6512172E677270635F736572766963652E426F6F6B696E6749641A1A2E677270635F736572766963652E436F6E6669726D6174696F6E123C0A0B726571756573744D656E7512162E676F6F676C652E70726F746F6275662E456D7074791A152E677270635F736572766963652E5468654D656E7512410A086E65774F72646572121A2E677270635F736572766963652E4F7264657244657461696C731A192E677270635F736572766963652E4F72646572526573756C74324D0A0677616974657212430A0A63617465724F72646572121A2E677270635F736572766963652E4F7264657244657461696C731A192E677270635F736572766963652E4F72646572526573756C74620670726F746F33",
        "google/protobuf/empty.proto":"0A1B676F6F676C652F70726F746F6275662F656D7074792E70726F746F120F676F6F676C652E70726F746F62756622070A05456D70747942540A13636F6D2E676F6F676C652E70726F746F627566420A456D70747950726F746F50015A057479706573F80101A20203475042AA021E476F6F676C652E50726F746F6275662E57656C6C4B6E6F776E5479706573620670726F746F33"
        
    };
}

