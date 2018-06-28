According to https://coreos.com/etcd/ "etcd is a distributed key value store that provides a reliable way to store data across a cluster of machines." 
Although default configurations do not listen on public ports, they also do not require authentication. Many systems deviate from this configuration and bind etcd to a public interface. This is a quick and dirty script to read an etcd store to download any information contained inside. The intent of this script is to enable security professionals who encounter etcd during a sanctioned assessment to download all the key values in the store so they can be examined to gain further network access.
The script connects to an etcd service (default port 2379) and lists all values in the key store. The script then downloads each value. Optionally, it will use a wordlist to brute force hidden keys. Should the etcd service use authentication, the script will accept either valid credentials or a valid certificate to authenticate to etcd. Other brute force tools, such as medusa, can help discover valid credentials. Valid certificates will have to be found elsewhere in the environment. 

Here are a few usage examples:
#connect to the etcd service on 127.0.0.1, port 2379 and download all visible key values
./etcdharvest.py --target=127.0.0.1:2379
#connect to the etcd service on 127.0.0.1, port 2379 and download all visible key values. Then brute force and download hidden values using the wordlist "testwordlist"
./etcdharvest.py --wordlist testwordlist --target=127.0.0.1:2379
#connect to the etcd service on 127.0.0.1, port 2379 using https and download all visible key values. Then brute force and download hidden values using the wordlist "testwordlist"
./etcdharvest.py --wordlist testwordlist --target=127.0.0.1:2379 --ssl
#connect to the etcd service on 127.0.0.1, port 2379 using the username root and password toor. Download all visible key values, then brute force and download hidden values using the wordlist "testwordlist"
./etcdharvest.py --creds root:toor --wordlist testwordlist --target=127.0.0.1:2379
#connect to the etcd service on 127.0.0.1, port 2379 using https and the specified certificates and download all visible key values. Then brute force and download hidden values using the wordlist "testwordlist"
./etcdharvest.py --wordlist testwordlist --target=127.0.0.1:2379 --ssl --cert ~/cfssl/client.pem --key ~/cfssl/client-key.pem