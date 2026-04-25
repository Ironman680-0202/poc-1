FROM amazoncorretto:21-alpine
WORKDIR /app
COPY app/target/poc-1-1.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]