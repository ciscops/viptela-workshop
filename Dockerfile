# Use an official Python runtime as a parent image
FROM dockerfile/python

COPY requirements.txt /data/

# Install requirements.
RUN pip install --requirement /data/requirements.txt

# Define working directory.
WORKDIR /data

# Define default command.
CMD ["bash"]