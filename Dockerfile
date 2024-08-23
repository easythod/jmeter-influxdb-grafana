FROM openjdk:8-jre AS build-env

ADD https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.4.1.zip /apache-jmeter.zip
RUN apt-get update && apt-get install -y unzip curl && unzip /apache-jmeter.zip -d /

RUN curl -L -o /usr/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && chmod u+x /usr/bin/jq

FROM openjdk:8-jre AS runtime-env


COPY --from=build-env /apache-jmeter-5.4.1 /jmeter
COPY --from=build-env /usr/bin/jq /usr/bin/jq

RUN ln -s /jmeter/bin/jmeter /usr/local/bin/jmeter

# Copy plugins folder under ext folder
COPY plugins/ /jmeter/lib/ext

# Change workdir to /jmeter
WORKDIR /jmeter
