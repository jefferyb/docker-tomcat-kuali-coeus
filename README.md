[![](https://images.microbadger.com/badges/version/jefferyb/kuali_tomcat.svg)](http://microbadger.com/images/jefferyb/kuali_tomcat "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/jefferyb/kuali_tomcat.svg)](http://microbadger.com/images/jefferyb/kuali_tomcat "Get your own image badge on microbadger.com")

# Kuali Coeus Tomcat Dockerfile

This repository contains the **Dockerfile** of an [ automated build of a Kuali Coeus Application/Tomcat image ](https://registry.hub.docker.com/u/jefferyb/kuali_tomcat/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).

# How to Use the Kuali Coeus Application/Tomcat Images

## Start a Kuali Coeus Application/Tomcat Instance

To use this image, you need a MySQL Kuali Coeus Database running, such as [ jefferyb/kuali_db_mysql ](https://registry.hub.docker.com/u/jefferyb/kuali_db_mysql/)

    docker run  -d --name kuali-coeus-database -p 3306:3306 jefferyb/kuali_db_mysql

and then start a Kuali Coeus Application/Tomcat instance as follows:

    docker run  -d \
                --name kuali-coeus-application \
                -e KUALI_APP_URL=EXAMPLE.COM \
                -e KUALI_APP_URL_PORT=8080 \
                -e MYSQL_HOSTNAME=kuali-coeus-database \
                --link kuali-coeus-database \
                -p 8080:8080 \
                jefferyb/kuali_tomcat

**NOTE:** This image needs at least 3 environment set:
  * `-e KUALI_APP_URL=EXAMPLE.COM` Where EXAMPLE.COM is the fqdn or IP address where you want to access it
  * `-e KUALI_APP_URL_PORT=8080` The external port set using -p
  * `-e MYSQL_HOSTNAME=kuali-coeus-database` The MySQL hostname. If you're linking dockers, then it will the container name of your database

## Build a Kuali Coeus Application/Tomcat Image yourself

You can build an image from the docker-compose.yml file:

    docker-compose build

Alternatively, you can build an image from the Dockerfile:

    docker build  -t jefferyb/kuali_tomcat https://github.com/jefferyb/docker-tomcat-kuali-coeus.git

## Watch the logs

You can check the logs using:

    docker logs -f kuali-coeus-application

## Access Kuali Coeus Application

To access the Kuali Coeus instance, go to:

    http://EXAMPLE.COM:8080/kc-dev

Where EXAMPLE.COM is what you set at `-e KUALI_APP_URL`

## Download the XML Files to ingest

To download the Kuali Coeus XML files, go to:

    For rice-xml
      http://EXAMPLE.COM:8080/xml_files/rice-xml.${Kuali-Coeus-Version}.zip

    For coeus-xml
      http://EXAMPLE.COM:8080/xml_files/coeus-xml.${Kuali-Coeus-Version}.zip

Where ${Kuali-Coeus-Version} is the version number on the http://EXAMPLE.COM:8080/kc-dev login page.

For example:
if the current version on the login page says: KualiCo 1606 MySQL
then to get the rice-xml and coeus-xml files, the links would be:

    http://EXAMPLE.COM:8080/xml_files/rice-xml.1506.69.zip
    http://EXAMPLE.COM:8080/xml_files/coeus-xml.1506.69.zip

## Container Shell Access

The `docker exec` command allows you to run commands inside a Docker container. The following command line will give you a bash shell inside your Kuali Coeus Application/Tomcat container:

    docker exec -it kuali-coeus-application bash

# Environment Variables

When you start/build the Kuali Coeus Application/Tomcat image, you can adjust the configuration of the Kuali Coeus Application/Tomcat instance by passing one or more environment variables on the `docker run` command line or `Dockerfile/docker-compose.yml` file.

Most of the variables listed below are optional, but at least `KUALI_APP_URL`, `KUALI_APP_URL_PORT`, `MYSQL_HOSTNAME` need to be there to get started...

## `KUALI_APP_URL`
The fqdn or IP address where you want to access your application
Default: KUALI_APP_URL="localhost"

## `KUALI_APP_URL_PORT`
The port number where you want to access your application
Default: KUALI_APP_URL_PORT="8080"

## `MYSQL_HOSTNAME`
The hostname of your MySQL instance. If you're linking dockers, then it will the container name of your database
Default: MYSQL_HOSTNAME="kuali-coeus-database"

## `MYSQL_PORT`
The MySQL port number
Default: MYSQL_PORT="3306"

## `MYSQL_USER`
The username to use.
Default: MYSQL_USER="kcusername"

## `MYSQL_PASSWORD`
The password for the username.
Default: MYSQL_PASSWORD="kcpassword"

## `MYSQL_DATABASE`
The name of the database.
Default: MYSQL_DATABASE="kualicoeusdb"
