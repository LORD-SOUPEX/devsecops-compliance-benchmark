FROM ubuntu:latest
MAINTAINER legacy-team@example.com
ADD http://example.invalid/app.tar.gz /app/
RUN apt-get update && apt-get install -y curl python3 wget
RUN cd /app && curl -s http://example.invalid/setup.sh | sh
RUN pip install flask
ENV DB_PASSWORD=hunter2
EXPOSE 22 8080
CMD python3 /app/server.py
