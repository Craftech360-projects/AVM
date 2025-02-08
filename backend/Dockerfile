FROM python:3.11 AS builder

ENV PATH="/opt/myenv/bin:$PATH"
RUN python -m venv /opt/myenv

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir --upgrade -r /tmp/requirements.txt

FROM python:3.11-slim

WORKDIR /app
ENV PATH="/opt/myenv/bin:$PATH"

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
  ffmpeg curl unzip libpq-dev gcc redis-server \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/myenv /opt/myenv
COPY . .

# Copy the Google credentials file
COPY google-credentials.json /app/google-credentials.json

RUN pip install --no-cache-dir celery psycopg2-binary

EXPOSE 8000
EXPOSE 6379

CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port 8000 "]

