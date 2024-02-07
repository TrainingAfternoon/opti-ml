FROM --platform=linux/amd64 python:3.9

WORKDIR /ml-compiler-opt
COPY . .
RUN pip install pipenv && pipenv sync --system && pipenv --clear
RUN apt-get install zlib1g-dev

WORKDIR /ml-compiler-opt/compiler_opt/tools
ENV PYTHONPATH=/ml-compiler-opt

VOLUME /external
