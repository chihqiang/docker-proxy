## docker（test）
~~~
docker rmi zhiqiangwang/proxy:squid && docker build -t zhiqiangwang/proxy:squid .
docker run -it --rm --name squid -p 3128:3128   zhiqiangwang/proxy:squid
curl -x http://squid:squid123@127.0.0.1:3128 ipinfo.io
~~~
