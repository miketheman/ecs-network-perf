FROM public.ecr.aws/docker/library/python:3.12-slim
ENV PYTHONUNBUFFERED=1

RUN apt update \
    && apt install gcc -y \
    && apt clean
RUN pip install --no-cache-dir poetry

WORKDIR /app

COPY poetry.lock pyproject.toml /app/
RUN poetry config virtualenvs.create false && poetry install --no-dev

COPY . /app

# We expose a port, despite not listening on it for Coilot CLI
EXPOSE 9999

CMD ["gunicorn", "-b", "unix:/tmp/gunicorn.sock", "-k", "uvicorn.workers.UvicornWorker", "example:app"]
