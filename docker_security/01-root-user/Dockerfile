FROM python:3.15.0b3-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

RUN useradd -m flaskapp

COPY . .

RUN chown -R flaskapp:flaskapp /app

USER flaskapp

EXPOSE 5000

CMD ["python", "app.py"]