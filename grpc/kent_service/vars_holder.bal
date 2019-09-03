
listener grpc:Listener ep = new (9000);
listener grpc:Listener welcomeEP = new (9001);
listener grpc:Listener tableEP = new (9002);
listener grpc:Listener waiterEP = new (9003);
map<TableDetails> tables = {};
int MAX_AVAILABLE_TABLE = 5;