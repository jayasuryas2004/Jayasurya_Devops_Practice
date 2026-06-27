FROM eclipse-temurin:17-jdk-focal

WORKDIR javaapp/

# The following COPY instruction copies the Maven wrappers and pom file from the host machine  
# to the container image.The pom.xml file contains information of project and configuration information 
# for the maven to build the project such as dependencies, build directory, source directory, test source directory, 
# plugin, goals etc.

COPY .mvn/ .mvn/

COPY .mvnw pom.xml ./

RUN .mvnw dependency:go-offline

COPY src ./src

CMD ["./mvnw","spring-boot:run"]