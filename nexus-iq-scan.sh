#!/bin/bash

echo Hello World
echo running Nexus IQ scan

./nexus-iq-cli -s http://localhost:8070 -a zwwu7vYv:8Uy6pVMKKLaZmyWjgwBuCAW4kUoVkqfAW7f1VWmzn2TU -i webgoat2 target/WebGoat-*.war
