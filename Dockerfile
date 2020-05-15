# ---- Base python ----
FROM python:alpine AS base
# Create app directory
WORKDIR /app

# ---- Copy Files/Lint ----
# FROM base AS lint  
# WORKDIR /app
# COPY . /app
# # lint
# RUN pip install --upgrade pip \
#     && pip install flake8
# RUN flake8 --ignore=E501,F401 .

# Build / Compile if required

# ---- Dependencies ----
FROM base AS dependencies  
# install app dependencies
COPY gunicorn_app/requirements.txt ./
RUN pip install -r requirements.txt
# RUN pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r requirements.txt


# ---- Copy Files/Build ----
FROM dependencies AS build  
WORKDIR /app
COPY . /app
# Build / Compile if required

# --- Release with Alpine ----
FROM base AS release  

COPY --from=dependencies /app/requirements.txt ./
COPY --from=dependencies /root/.cache /root/.cache

# Install app dependencies
RUN pip install -r requirements.txt
COPY --from=build /app/ ./
CMD ["gunicorn", "--config", "./gunicorn_app/conf/gunicorn_config.py", "gunicorn_app:app"]