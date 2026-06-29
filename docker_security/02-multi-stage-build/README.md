# Docker Security Lab 3 – Multi-Stage Builds

## Objective

Learn how to create production-ready Docker images using Multi-Stage Builds.

Instead of shipping build tools like Maven to production, build the application in one stage and run it in another stage with only the required runtime.

---

# Why Multi-Stage Builds?

A single-stage Docker image usually contains:

- Source code
- Maven
- Build cache
- Git
- Test files
- Build dependencies

These are required only during the build process.

In production, the application only needs:

- Java Runtime (JRE)
- Application JAR

Everything else increases:

- Image size
- Attack surface
- CVEs
- Build time

---

# Project Structure

```
02-multi-stage-build/
│
├── Dockerfile
├── pom.xml
├── README.md
└── src/
    └── main/
        ├── java/
        └── resources/
```

---

# Builder Stage

Purpose:

- Compile Java source code
- Download dependencies
- Create executable JAR

Uses:

- Maven
- JDK

Output:

```
target/spring-demo-1.0.0.jar
```

---

# Runtime Stage

Purpose:

Run only the application.

Contains:

- Java Runtime
- app.jar
- Non-root user

Does NOT contain:

- Maven
- Source code
- pom.xml
- Git
- Maven cache

---

# Dockerfile Concepts

## Stage 1

- FROM maven image
- WORKDIR
- COPY source code
- RUN mvn clean package

Purpose:

Build the executable JAR.

---

## Stage 2

- FROM JRE image
- COPY only app.jar
- Create non-root user
- Change ownership
- Switch to non-root user
- Expose application port
- Start application

Purpose:

Create a minimal production image.

---

# Commands

## Build Image

```bash
docker build --no-cache -t spring-demo:multi .
```

---

## List Images

```bash
docker image ls
```

---

## Run Container

```bash
docker run -d \
--name spring-app \
-p 8080:8080 \
spring-demo:multi
```

---

## Check Running Containers

```bash
docker ps
```

---

## Check Logs

```bash
docker logs spring-app
```

---

## Enter Container

```bash
docker exec -it spring-app sh
```

---

## Verify User

```bash
whoami
```

Expected:

```
javaapp
```

---

## Verify User ID

```bash
id
```

Expected:

```
uid=1000(javaapp)
```

---

## Verify Maven is NOT Installed

```bash
mvn -version
```

Expected:

```
mvn: command not found
```

---

## Verify Application Files

```bash
ls -l /app
```

Expected:

```
app.jar
```

Should NOT exist:

- src/
- pom.xml
- .m2
- Git

---

## Security Verification

Attempt:

```bash
apt update
```

Expected:

```
Permission denied
```

Attempt:

```bash
touch /etc/test
```

Expected:

```
Permission denied
```

Reason:

Container runs as a non-root user.

---

# Problems Faced During Lab

## Issue 1

Compilation Error

```
DemoApplication is public,
should be declared in a file named DemoApplication.java
```

Cause:

Java filename did not match public class name.

Solution:

Rename file to:

```
DemoApplication.java
```

---

## Issue 2

Container exited immediately.

Logs:

```
no main manifest attribute
```

Cause:

Spring Boot Maven Plugin was missing.

Solution:

Added:

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
        </plugin>
    </plugins>
</build>
```

---

## Issue 3

Docker build failed with:

```
Expected root element 'project'
```

Cause:

Incorrect XML structure in pom.xml.

Solution:

Placed the `<build>` section inside the `<project>` element.

---

# Security Benefits

✔ Smaller image

✔ Less attack surface

✔ No Maven in production

✔ No source code in production

✔ Faster deployment

✔ Faster image pull

✔ Fewer CVEs

✔ Non-root execution

---

# Interview Questions

### Why use Multi-Stage Builds?

To separate the build environment from the runtime environment and produce smaller, more secure production images.

---

### Why remove Maven?

Maven is required only for building the application.

Production only needs the compiled JAR.

---

### Why copy only app.jar?

To avoid shipping unnecessary files such as:

- Source code
- Build cache
- pom.xml
- Git metadata

---

### Why create a non-root user?

If an attacker compromises the application, they gain limited privileges instead of root access.

---

### Difference Between Builder and Runtime

| Builder Stage | Runtime Stage |
|---------------|---------------|
| Maven | JRE |
| JDK | Runtime Only |
| Source Code | app.jar |
| Build Dependencies | Application Only |
| Large Image | Small Image |

---

# Key Learnings

- Multi-Stage Builds
- Builder Stage
- Runtime Stage
- Executable Spring Boot JAR
- COPY --from
- Non-root user
- Minimal runtime image
- Docker security best practices