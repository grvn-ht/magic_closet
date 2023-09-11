FROM python:3.10-alpine

ENV SRC_DIR /usr/src/app

WORKDIR ${SRC_DIR}

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN pip install --upgrade pip

RUN pip install pipenv

COPY Pipfile Pipfile.lock ./

RUN pipenv install --system --deploy 

COPY back_python ./

# Add Pipenv virtual environment to PATH
#ENV PATH="${SRC_DIR}/.venv/bin:$PATH"

EXPOSE 5000
#["pipenv", "run", "gunicorn", "main:app", "--bind", "0.0.0.0:8000"]
CMD ["gunicorn", "--graceful-timeout", "5","main:app", "-b", "0.0.0.0:5000","--log-level","warning"]