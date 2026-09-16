#-------------------------------------------------------------------------------
# Settings

# Library versions
ARG PYTHON_TORCH_VERSION=2.11.0
ARG PYTHON_TF_VERSION=2.21.0
ARG PYTHON_ONNXSCRIPT_VERSION=0.7.0
ARG PYTHON_MUJOCO_VERSION=3.7.0
ARG PYTHON_GYMNASIUM_VERSION=1.2.3
ARG PYTHON_JUPYTERLAB_VERSION=4.5.6
ARG PYTHON_TENSORBOARD_VERSION=2.20.0
ARG PYTHON_TENSORBOARDX_VERSION=2.6.5
ARG PYTHON_MEDIAPY_VERSION=1.2.6
ARG PYTHON_MATPLOTLIB_VERSION=3.10.8
ARG PYTHON_ONNX_VERSION=1.21.0
ARG PYTHON_ONNXRUNTIME_VERSION=1.25.1

#-------------------------------------------------------------------------------
# Base image and dependencies
# Use the official Python slim image to avoid pyenv compilation overhead
FROM python:3.12-slim

# Redeclare arguments
ARG PYTHON_TORCH_VERSION
ARG PYTHON_TF_VERSION
ARG PYTHON_ONNXSCRIPT_VERSION
ARG PYTHON_MUJOCO_VERSION
ARG PYTHON_GYMNASIUM_VERSION
ARG PYTHON_JUPYTERLAB_VERSION
ARG PYTHON_TENSORBOARD_VERSION
ARG PYTHON_TENSORBOARDX_VERSION
ARG PYTHON_MEDIAPY_VERSION
ARG PYTHON_MATPLOTLIB_VERSION
ARG PYTHON_ONNX_VERSION
ARG PYTHON_ONNXRUNTIME_VERSION
ARG TARGETARCH

SHELL ["/bin/bash", "-c"]

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies required for MuJoCo headless rendering
RUN apt-get -y update && \
    apt-get -y install \
        build-essential \
        curl \
        git \
        libegl1-mesa-dev \
        libgl1-mesa-dev \
        libgles2-mesa-dev \
        libglfw3 \
        libglfw3-dev \
        libosmesa6 \
        libosmesa6-dev \
        nano \
        wget \
        && apt-get clean -y && \
        apt-get autoremove --purge -y && \
        rm -rf /var/lib/apt/lists/*

#-------------------------------------------------------------------------------
# Workspace Setup
WORKDIR /workspace

#-------------------------------------------------------------------------------
# Python environment
# We install directly into the system python since Docker provides isolation
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# PyTorch (CPU)
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        pip install --no-cache-dir torch==${PYTHON_TORCH_VERSION} --index-url https://download.pytorch.org/whl/cpu; \
    else \
        pip install --no-cache-dir torch==${PYTHON_TORCH_VERSION}; \
    fi

# TensorFlow CPU, MuJoCo, and RL libraries
RUN pip install --no-cache-dir \
    tensorflow-cpu==${PYTHON_TF_VERSION} \
    onnxscript==${PYTHON_ONNXSCRIPT_VERSION} \
    mujoco==${PYTHON_MUJOCO_VERSION} \
    "gymnasium[mujoco]==${PYTHON_GYMNASIUM_VERSION}" \
    tensorboard==${PYTHON_TENSORBOARD_VERSION} \
    tensorboardX==${PYTHON_TENSORBOARDX_VERSION} \
    mediapy==${PYTHON_MEDIAPY_VERSION} \
    matplotlib==${PYTHON_MATPLOTLIB_VERSION} \
    onnx==${PYTHON_ONNX_VERSION} \
    onnxruntime==${PYTHON_ONNXRUNTIME_VERSION} \
    jupyterlab==${PYTHON_JUPYTERLAB_VERSION}

#-------------------------------------------------------------------------------
# MuJoCo rendering environment variables
# EGL allows hardware-accelerated headless rendering without an X11 desktop server
ENV MUJOCO_GL=egl
ENV PYOPENGL_PLATFORM=egl

#-------------------------------------------------------------------------------
# Entrypoint

# Expose ports for JupyterLab and TensorBoard
EXPOSE 8888 6006

# Start JupyterLab by default
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]