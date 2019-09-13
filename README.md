# postgresql-9.1-postgis-1.5

base on reverse engineering docker.hub https://hub.docker.com/r/iggdrasil/postgis-1.5 

use to reverse engineering https://github.com/LanikSJ/dfimage

sudo docker pull laniksj/dfimage
alias dfimage="sudo docker run -v /var/run/docker.sock:/var/run/docker.sock --rm laniksj/dfimage"
dfimage imageID

user@vm-dev-01:/mnt/data/project/soulcore/xxx_pg91_gs15$

build ( correct the path and tag )
sudo docker build --file "/mnt/data/project/soulcore/xxx_pg91_gs15/Dockerfile" --tag soulcore/postgresql-postgis:9.1-1.5 .

push ( store at docker.hub)
sudo docker push soulcore/postgresql-postgis:9.1-1.5