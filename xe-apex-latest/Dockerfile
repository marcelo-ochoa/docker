FROM	oracle/database:11.2.0.2-xe
MAINTAINER mochoa@scotas.com

ENV APEX_FILE=apex_5.1_en.zip

COPY $APEX_FILE $INSTALL_DIR/

RUN cd $INSTALL_DIR  && \
    unzip $APEX_FILE && \
    rm $APEX_FILE && \
    chmod u+x $ORACLE_BASE/$RUN_FILE
    
COPY 	runOracle.sh $ORACLE_BASE/

VOLUME ["$ORACLE_BASE/oradata"]
EXPOSE 1521 8080

CMD $ORACLE_BASE/$RUN_FILE
