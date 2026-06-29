FROM maven:3.9.9-eclipse-temurin-21 AS builder

WORKDIR /app

COPY . .

RUN mvn clean package

# STAGE 2

FROM eclipse-temurin:21-jre

WORKDIR /app

COPY --from=builder /app/target/spring-demo-1.0.0.jar /app/app.jar

RUN useradd -m javaapp

RUN chown -R javaapp:javaapp /app

USER javaapp

EXPOSE 8080

CMD ["java","-jar","/app/app.jar"]

