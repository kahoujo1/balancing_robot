# Balancing Robot using RL

## Installation
**1.) Build the docker image**
```bash
docker image build -t rl-headless .
```
**2.) Run the container**
```bash
xhost +local:docker # allow to project displays
docker run -it -p 8888:8888 -p 6006:6006 \
  --device /dev/dri \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $(pwd)/workspace:/workspace \
  rl-headless
```

**3.) Open additional terminal**
```bash
docker exec -it <CONTAINER_NAME> /bin/bash
```