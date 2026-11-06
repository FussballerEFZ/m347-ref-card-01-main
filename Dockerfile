# ---------- Build-Stage: Anwendung mit Maven bauen ----------
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

# Zuerst nur die pom.xml kopieren, damit die Dependencies gecacht werden
COPY pom.xml .
RUN mvn -B dependency:go-offline

# Quellcode kopieren und das JAR bauen (Tests laufen in der CI-Pipeline)
COPY src ./src
RUN mvn -B clean package -DskipTests

# ---------- Runtime-Stage: schlankes Image nur mit JRE ----------
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Nicht als root laufen
RUN addgroup -S spring && adduser -S spring -G spring
USER spring

COPY --from=build /app/target/*.jar app.jar

LABEL org.opencontainers.image.source="https://github.com/FussballerEFZ/m347-ref-card-01-main"

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
