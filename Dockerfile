FROM ubuntu:latest

WORKDIR /yougile

ARG VERSION
ARG EDITOR
ENV VERSION=$VERSION
ENV EDITOR=$EDITOR


ADD https://dist.yougile.com/linux/${VERSION}/yougile.tar.gz /tmp/yougile.tar.gz

COPY ./yougilestart.sh yougilestart.sh

RUN apt-get update && apt-get install -y $EDITOR \
	&& tar xf /tmp/yougile.tar.gz -C / \
	&& rm -rf /tmp/* \
	&& touch license.key machine.key \
	chmod +x yougilestart.sh 

ENTRYPOINT ["/yougile/yougilestart.sh"]




