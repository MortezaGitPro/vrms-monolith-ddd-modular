# -------- Build Stage --------
FROM gradle:8-jdk17 AS builder
WORKDIR /app
COPY . .
RUN gradle bootJar --no-daemon

# -------- Runtime Stage --------
FROM amazoncorretto:17
WORKDIR /app
COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
