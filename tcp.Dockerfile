FROM python:3-slim
ENV PYTHONUNBUFFERED=1

RUN apt-get update \
    && apt-get install gcc -y \
    && apt-get clean
RUN pip install --no-cache-dir poetry

WORKDIR /app

COPY poetry.lock pyproject.toml /app/
RUN poetry config virtualenvs.create false && poetry install --no-dev

COPY . /app

EXPOSE 8000
CMD ["gunicorn", "-b", "0.0.0.0:8000", "-k", "uvicorn.workers.UvicornWorker", "example:app"]
