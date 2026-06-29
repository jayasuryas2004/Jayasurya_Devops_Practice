# Docker Security Lab 01 - Running Containers as Non-Root User

## Objective

Learn why running containers as the **root user** is a security risk and how to secure the container by running the application as a **non-root user**.

---

# Project Structure

```
01-root-user/
│
├── app.py
├── requirements.txt
├── Dockerfile
└── README.md
```

---

# Prerequisites

- Docker Desktop
- Docker CLI
- Python Flask Application

---

# Step 1 - Create Flask Application

Create a simple Flask application.

Endpoints

```
/
```

Returns

```json
{
    "message": "Hello from Docker",
    "status": "success"
}
```

Health endpoint

```
/health
```

Returns

```json
{
    "status":"healthy"
}
```

---

# Step 2 - Create Initial Dockerfile (Insecure)

Initially, create the Docker image **without** specifying a USER instruction.

Reason:

We want to understand Docker's default behavior.

---

# Step 3 - Build Docker Image

```bash
docker build -t my-python-app .
```

---

# Step 4 - Run Container

```bash
docker run -d -p 5000:5000 --name flask_container my-python-app
```

Verify

```bash
docker ps
```

---

# Step 5 - Enter Container

```bash
docker exec -it flask_container sh
```

---

# Step 6 - Verify Running User

```bash
whoami
```

Output

```
root
```

Check UID

```bash
id
```

Output

```
uid=0(root)
gid=0(root)
groups=0(root)
```

## Observation

The application is running as the root user.

This is Docker's default behavior.

---

# Step 7 - Simulate Attacker Actions

Try creating files in system locations.

```bash
touch /hacked.txt
```

Verify

```bash
ls /
```

Result

```
hacked.txt
```

Create directory

```bash
mkdir /opt/security-test
```

Modify system directory

```bash
touch /etc/testfile
```

Verify

```bash
ls /etc | grep testfile
```

Try package installation

```bash
apt update
```

## Observation

Everything works because the application is running as **root**.

---

# Security Risk

If an attacker exploits the Flask application:

- Can modify system files
- Can install packages
- Can create malicious files
- Can perform privileged operations
- Has root privileges inside the container

This violates the **Principle of Least Privilege**.

---

# Step 8 - Secure the Container

Create a dedicated application user.

Update Dockerfile.

```dockerfile
FROM python:3.15.0b3-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

RUN useradd -m flaskapp

COPY . .

RUN chown -R flaskapp:flaskapp /app

USER flaskapp

EXPOSE 5000

CMD ["python","app.py"]
```

---

# Why This Order?

## Install dependencies first

Requires root privileges.

```
RUN pip install
```

---

## Create application user

```
RUN useradd -m flaskapp
```

---

## Copy application

```
COPY . .
```

---

## Change ownership

```
RUN chown -R flaskapp:flaskapp /app
```

Allows flaskapp to access application files.

---

## Switch user

```
USER flaskapp
```

Everything after this line runs as flaskapp.

---

# Step 9 - Rebuild Image

```bash
docker build -t my-python-app .
```

---

# Step 10 - Remove Old Container

```bash
docker rm -f flask_container
```

---

# Step 11 - Run New Container

```bash
docker run -d -p 5000:5000 --name my_flask_app my-python-app
```

---

# Step 12 - Verify New User

Enter container

```bash
docker exec -it my_flask_app sh
```

Check user

```bash
whoami
```

Output

```
flaskapp
```

Check UID

```bash
id
```

Output

```
uid=1000(flaskapp)
gid=1000(flaskapp)
```

---

# Step 13 - Test Again

Create file inside application directory

```bash
touch hello.txt
```

Works because flaskapp owns `/app`.

---

Try installing packages

```bash
apt update
```

Output

```
Permission denied
```

---

Try modifying protected directories

```bash
touch /etc/testfile
```

Expected

```
Permission denied
```

---

Try creating file in root directory

```bash
touch /hacked.txt
```

Expected

```
Permission denied
```

---

# Comparison

| Root User | Non-Root User |
|------------|---------------|
| uid=0 | uid=1000 |
| Can install packages | Permission denied |
| Can modify /etc | Permission denied |
| Can modify / | Permission denied |
| High attack surface | Reduced attack surface |
| Violates least privilege | Follows least privilege |

---

# Docker Commands Used

Build Image

```bash
docker build -t my-python-app .
```

Run Container

```bash
docker run -d -p 5000:5000 --name my_flask_app my-python-app
```

List Running Containers

```bash
docker ps
```

List All Containers

```bash
docker ps -a
```

Enter Container

```bash
docker exec -it my_flask_app sh
```

Container Logs

```bash
docker logs my_flask_app
```

Stop Container

```bash
docker stop my_flask_app
```

Remove Container

```bash
docker rm -f my_flask_app
```

Remove Image

```bash
docker rmi my-python-app
```

---

# Key Security Concepts Learned

- Docker containers run as root by default.
- Root inside a container has elevated privileges within that container.
- Running applications as a non-root user reduces the impact of a compromise.
- Use the `USER` instruction to follow the Principle of Least Privilege.
- Build-time operations can require root, but runtime should use a dedicated application user.
- Change ownership of application files before switching to a non-root user.

---

# Interview Questions

### Why should containers avoid running as root?

Because if an attacker compromises the application, they inherit the application's privileges. Running as a non-root user limits what the attacker can do inside the container.

---

### Why is USER placed near the end of the Dockerfile?

All privileged build operations (installing packages, creating users, changing ownership) require root. After these tasks are complete, the application should run as a non-root user.

---

### What is the Principle of Least Privilege?

Applications should have only the permissions required to perform their tasks and nothing more.

---

# Lab Completed

✅ Built a Flask application

✅ Built a Docker image

✅ Verified the default root user

✅ Simulated privileged operations

✅ Created a dedicated application user

✅ Switched runtime to a non-root user

✅ Verified restricted permissions

✅ Understood Docker's USER instruction and container hardening