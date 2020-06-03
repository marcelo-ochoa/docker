FROM oracle/nosql

LABEL maintainer="marcelo.ochoa@gmail.com"

ADD start-nosql.sh /start-nosql.sh
RUN chmod +x /start-nosql.sh && mkdir -p /data /kvroot

EXPOSE	5000 5001 5010-5020
VOLUME [ "/data" ,"/kvroot" ]

CMD /start-nosql.sh
