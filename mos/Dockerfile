FROM python:3.10-alpine

ENV SRC_DIR /usr/src/app

WORKDIR ${SRC_DIR}

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN pip install pipenv

COPY Pipfile Pipfile.lock ./

RUN pipenv install --system --deploy 

COPY mos ./

# Add Pipenv virtual environment to PATH
#ENV PATH="${SRC_DIR}/.venv/bin:$PATH"

CMD ["python", "mos_sub.py"]