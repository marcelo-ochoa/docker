FROM	oracle-rdbms:12.1.0.2
MAINTAINER mochoa@scotas.com
WORKDIR	/home/oracle
ADD	http://www.scotas.com/download/ols/lucene-ols-bin-2.0.1.zip /home/oracle/
ADD	http://www.scotas.com/download/ols/valid.ols /home/oracle/
ADD	http://www.scotas.com/download/ols/ODCI.jar /home/oracle/
RUN	chown -R oracle:oinstall /home/oracle/lucene-ols-bin-2.0.1.zip
RUN	chown -R oracle:oinstall /home/oracle/valid.ols
RUN	chown -R oracle:oinstall /home/oracle/ODCI.jar
USER	oracle
RUN	unzip /home/oracle/lucene-ols-bin-2.0.1.zip -d /home/oracle/
RUN	cp /home/oracle/valid.ols /home/oracle/ols/bin/com/scotas/license
RUN	rm -f /home/oracle/lucene-ols-bin-2.0.1.zip
USER	root
ADD	manage-oracle.sh /home/oracle/
EXPOSE	1521 9099 9999
CMD	[ "sh" , "-c" ,  "/home/oracle/manage-oracle.sh" ]
