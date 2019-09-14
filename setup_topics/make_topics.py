import os

f = open("topics.txt", "r")
topics = f.read().split("\n")
for t in topics:
    if t == "":
        continue
    os.system("bin/kafka-topics.sh --create --topic "+t+" --zookeeper localhost:2181 --replication-factor 1 --partitions 2")
