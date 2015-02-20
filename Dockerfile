FROM ubuntu:14.04
MAINTAINER "Rohan Singh <rohan@washington.edu>"

ENV DEBIAN_FRONTEND noninteractive

# defaults for debify
ENV APTLY_DISTRIBUTION unstable
ENV APTLY_COMPONENT main
ENV KEYSERVER keyserver.ubuntu.com

ENV GNUPGHOME /.gnupg

# install aptly
RUN echo deb http://repo.aptly.info/ squeeze main >> /etc/apt/sources.list
RUN apt-key adv --keyserver keys.gnupg.net --recv-keys E083A3782A194991
RUN apt-get update && \
    apt-get install -y aptly && \
    apt-get clean

ADD debify.sh /debify.sh
ENTRYPOINT ["/debify.sh"]
