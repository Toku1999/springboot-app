# -------- Stage 1: Build Stage --------
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /app

# Copy all project files
COPY . .

# Build the application
RUN mvn clean package -DskipTests


# -------- Stage 2: Runtime Stage --------
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy only JAR file from build stage
COPY --from=build /app/target/*.jar app.jar

# Expose application port
EXPOSE 8080

# Run application
CMD ["java", "-jar", "app.jar"]
