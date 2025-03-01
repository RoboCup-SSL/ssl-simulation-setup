FROM python:3.13-alpine
RUN apk add --no-cache socat
CMD [ "/multisocat.py" ]
COPY  multisocat.py /multisocat.py
RUN chmod 0755 /multisocat.py
USER nobody
