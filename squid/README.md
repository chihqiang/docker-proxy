## docker（test）
~~~
podman rmi zhiqiangwang/proxy:squid && podman build -t zhiqiangwang/proxy:squid .
podman run -it --rm --name squid -p 3128:3128   zhiqiangwang/proxy:squid
curl -x http://squid:squid123@localhost:3128 ipinfo.io
~~~
