# syntax=docker/dockerfile:1

FROM python:3.8-alpine
COPY ./requirements.txt /my-app/requirements.txt
WORKDIR /my-app
RUN pip install -r requirements.txt
COPY . /app
ENTRYPOINT [ "python" ]
CMD ["app.py" ]
