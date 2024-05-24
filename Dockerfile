FROM ubuntu:noble

RUN apt update \
  && DEBIAN_FRONTEND=noninteractive TZ=America/Denver apt install -y asterisk mpg123

RUN mkdir -p /usr/share/asterisk/sounds/custom/builtin \
  && mkdir -p /usr/share/asterisk/sounds/custom/external

COPY --chown=asterisk:asterisk conf/*.conf /etc/asterisk/
COPY --chown=asterisk:asterisk sounds/builtin/*.mp3 /usr/share/asterisk/sounds/custom/builtin
COPY --chown=asterisk:asterisk --chmod=755 scripts/*.sh /usr/share/asterisk/agi-bin/

CMD /usr/sbin/asterisk -f -p -U asterisk
