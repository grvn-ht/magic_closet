# Use the official Flutter image as the base image
FROM instrumentisto/flutter:3.13.2 AS build-env

# Set environment variables
ENV FLUTTER_HOME=/flutter
ENV PATH=${FLUTTER_HOME}/bin:${PATH}

# Create a directory for the Flutter app and set it as the working directory
WORKDIR /app

# Copy the pubspec.yaml and pubspec.lock files to get dependencies
COPY pubspec.yaml pubspec.yaml
COPY pubspec.lock pubspec.lock

# Run 'flutter pub get' to fetch the Flutter app dependencies
RUN flutter pub get

# Copy the rest of the app source code
COPY . .

# Build the Flutter app (replace 'web' with the target platform, e.g., 'web' for web apps)
RUN flutter build web


# Stage 2 - Create the run-time image
#FROM nginx:1.21.1-alpine
#COPY --from=build-env /app/build/web /usr/share/nginx/html