FROM postgres:15

RUN localedef -i nl_NL -c -f UTF-8 -A /usr/share/locale/locale.alias nl_NL.UTF-8
ENV LANG nl_NL.utf8
RUN apt-get update && \
apt-get install -y sudo vim curl wget unzip jq

EXPOSE 5432
