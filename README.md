# Balancing Robot using RL

## Installation
**1.) Build the docker image**
```bash
docker image build -t rl-headless .
```
**2.) Run the container**
```bash
docker run -it -p 8888:8888 -p 6006:6006 -v $(pwd):/workspace rl-headless
```

**3.) Open additional terminal**
```bash
docker exec -it <CONTAINER_NAME> /bin/bash
```