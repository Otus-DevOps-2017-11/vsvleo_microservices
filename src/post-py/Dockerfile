FROM python:3.6.0-alpine

RUN pip install --upgrade pip
RUN pip install flask pymongo

WORKDIR /app
ADD . /app

RUN apk add --no-cache gcc musl-dev
RUN pip install -r requirements.txt

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

CMD ["python3", "post_app.py"]
