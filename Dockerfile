# Use an official Python runtime as a parent image
FROM ubuntu:18.04

RUN apt-get update && apt-get install -y python-pip

COPY requirements.txt /data/

# Install requirements.
RUN pip install --requirement /data/requirements.txt

# Define working directory.
WORKDIR /data

# Define default command.
CMD ["bash"]