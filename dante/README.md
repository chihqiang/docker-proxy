## docker（test）
~~~
docker build -t zhiqiangwang/proxy:dante .
docker run -it --rm --name dante  -p 1080:1080  zhiqiangwang/proxy:dante
curl --socks5 127.0.0.1:1080  ipinfo.io
~~~
