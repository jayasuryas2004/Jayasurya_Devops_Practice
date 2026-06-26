npm init is a command used to initialize a new Node.js project. It creates a package.json file, which stores metadata and dependency information for your application.

npm init -y

The -y flag means "yes to all defaults", so npm automatically generated this file:

{
  "name": "docker-optimization-lab",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "description": ""
}


package.json?

Think of it as the configuration file for your Node.js project. It contains:

Field	Purpose
name	Project name
version	Application version
main	Entry point file
scripts	Commands you can run
dependencies	Installed packages
author	Project author
license	License type

npm install express

npm added Express to your project and updated package.json:

{
  "dependencies": {
    "express": "^5.1.0"
  }
}

It also created:

node_modules/ → contains installed packages
package-lock.json → locks exact package versions


# Security Analysis

Scan both images for vulnerabilities and compare results.
Commands to Run

docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy app:basic

docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy app:optimized

💡 Hints

    Install Trivy if not available
    Compare vulnerability counts between images

Validation Criteria

    Security scan completes
    Vulnerability comparison documented