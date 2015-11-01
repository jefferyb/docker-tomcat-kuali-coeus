#
# Kuali Coeus on tomcat Dockerfile
# This docker image works with the jefferyb/kuali_db_mysql docker image...
#
# https://github.com/jefferyb/docker-tomcat-kuali-coeus
#
# To Build:
#    docker build -t jefferyb/kuali_tomcat .
#
# To Run:
#    docker run -d --name kuali_db_mysql -h kuali_db_mysql -p 43306:3306 jefferyb/kuali_db_mysql
#    docker run -d --name kuali_tomcat -h EXAMPLE.COM --link kuali_db_mysql:kuali_db_mysql -p 8080:8080 jefferyb/kuali_tomcat

# Pull base image.
FROM ubuntu:14.04
MAINTAINER Jeffery Bagirimvano <jeffery.rukundo@gmail.com>

# Kuali Release File
ENV KC_CONFIG_XML_LOC="/opt/kuali/main/dev"

# TOMCAT RELATED
ENV TOMCAT_LOCATION="/opt/apache-tomcat/tomcat8"

# MySQL Connector Java
ENV MYSQL_CONNECTOR_LINK="http://mirror.cogentco.com/pub/mysql/Connector-J/mysql-connector-java-5.1.34.zip"
ENV MYSQL_CONNECTOR_ZIP_FILE="mysql-connector-java-5.1.34.zip"
ENV MYSQL_CONNECTOR_FILE="mysql-connector-java-5.1.34/mysql-connector-java-5.1.34-bin.jar"

# Tomcat - Spring Instrumentation
ENV SPRING_INSTRUMENTATION_TOMCAT_LINK="http://central.maven.org/maven2/org/springframework/spring-instrument-tomcat/3.2.13.RELEASE/spring-instrument-tomcat-3.2.13.RELEASE.jar"

RUN mkdir -p /SetupTomcat

ADD SetupTomcat /SetupTomcat

# Install Tomcat.
RUN \
  apt-get update && \
  apt-get install -y curl && \
  TOMCAT_MAJOR="8" && \
  TOMCAT_VERSION="$(curl -s https://tomcat.apache.org/download-80.cgi | grep -A 7 '</select><input type="submit" value="Change">' | grep '<h3 id="' | sed 's/<h3 id="//' | sed 's/">.*//')" && \
  TOMCAT_LINK="https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz" && \
  TOMCAT_FILE="apache-tomcat-${TOMCAT_VERSION}.tar.gz" && \

  apt-get install -y software-properties-common && \
	add-apt-repository -y ppa:webupd8team/java && \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
	apt-get update && \
	apt-get install -y wget zip unzip oracle-java8-installer tar graphviz && \
	cd /SetupTomcat  && \
	wget ${TOMCAT_LINK} && \
	mkdir -p ${TOMCAT_LOCATION} && \
	tar --strip-components=1 -zxvf ${TOMCAT_FILE} -C ${TOMCAT_LOCATION} && \
	wget ${MYSQL_CONNECTOR_LINK} && \
	unzip -j ${MYSQL_CONNECTOR_ZIP_FILE} ${MYSQL_CONNECTOR_FILE} -d ${TOMCAT_LOCATION}/lib && \
	cp /SetupTomcat/setenv.sh ${TOMCAT_LOCATION}/bin && \
	cd ${TOMCAT_LOCATION}/lib && \
	wget ${SPRING_INSTRUMENTATION_TOMCAT_LINK} && \
	sed -i 's/<Context>/<Context>\n    <!-- END - For Kuali Coeus - Jeffery B. -->/' ${TOMCAT_LOCATION}/conf/context.xml && \
	sed -i 's/<Context>/<Context>\n    <Loader loaderClass="org.springframework.instrument.classloading.tomcat.TomcatInstrumentableClassLoader"\/>/' ${TOMCAT_LOCATION}/conf/context.xml && \
	sed -i 's/<Context>/<Context>\n\n    <!-- BEGIN - For Kuali Coeus -->/' ${TOMCAT_LOCATION}/conf/context.xml && \
	mkdir -p ${KC_CONFIG_XML_LOC} && \
	cp -f /SetupTomcat/kc-config.xml ${KC_CONFIG_XML_LOC}/kc-config.xml && \

  KC_VERSION="$(curl -s https://raw.githubusercontent.com/kuali/kc/master/pom.xml | egrep -m 1 "<version>" | sed 's/<version>//' | sed 's/\..*//' | awk '{print $1}')" && \
	KC_WAR_FILE_LINK="http://www.kuali.erafiki.com/${KC_VERSION}/mysql/kc-dev.war" && \
	KC_PROJECT_RICE_XML="http://www.kuali.erafiki.com/${KC_VERSION}/xml_files/rice-xml-${KC_VERSION}.zip" && \
	KC_PROJECT_COEUS_XML="http://www.kuali.erafiki.com/${KC_VERSION}/xml_files/coeus-xml-${KC_VERSION}.zip" && \

	wget ${KC_WAR_FILE_LINK} -O ${TOMCAT_LOCATION}/webapps/kc-dev.war && \
	mkdir -p ${TOMCAT_LOCATION}/webapps/ROOT/xml_files && \
	wget ${KC_PROJECT_RICE_XML} -O ${TOMCAT_LOCATION}/webapps/ROOT/xml_files/rice-xml-$(echo ${KC_VERSION} | sed 's/coeus-//').zip && \
	wget ${KC_PROJECT_COEUS_XML} -O ${TOMCAT_LOCATION}/webapps/ROOT/xml_files/coeus-xml-$(echo ${KC_VERSION} | sed 's/coeus-//').zip && \
	rm -fr /SetupTomcat && \
	echo "Done!!!"

# Expose ports.
EXPOSE 8080

# Define default command.
CMD export TERM=vt100; sed -i "s/localhost/$(hostname -f)/" ${KC_CONFIG_XML_LOC}/kc-config.xml; sed -i "s/Kuali-Coeus-Version/${KC_VERSION}/" ${KC_CONFIG_XML_LOC}/kc-config.xml; ${TOMCAT_LOCATION}/bin/startup.sh; tailf ${TOMCAT_LOCATION}/logs/catalina.out
