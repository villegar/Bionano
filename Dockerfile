FROM centos:latest

# Identify the maintainer of an image
LABEL name="Bionano Access Server" \
    author="Roberto Villegas-Diaz" \
    maintainer="Roberto.VillegasDiaz@sdstate.edu"

# install Perl
RUN yum install -y perl

# install Java
RUN yum install -y java-1.8.0-openjdk

# install Python
RUN yum install -y python36

# install nodejs
RUN curl -sL https://rpm.nodesource.com/setup_8.x | bash -
RUN yum install -y --skip-broken nodejs

# install postgresql
RUN yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
RUN yum -qy module disable postgresql
RUN yum -y install postgresql12 postgresql12-server
# RUN yum install -y postgresql12 postgresql-12-server
RUN yum install -y postgresql12-contrib

RUN yum -y install systemd; yum clean all;
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done);
RUN rm -f /lib/systemd/system/multi-user.target.wants/*;
RUN rm -f /etc/systemd/system/*.wants/*;
RUN rm -f /lib/systemd/system/local-fs.target.wants/*;
RUN rm -f /lib/systemd/system/sockets.target.wants/*udev*;
RUN rm -f /lib/systemd/system/sockets.target.wants/*initctl*;
RUN rm -f /lib/systemd/system/basic.target.wants/*;
RUN rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ “/sys/fs/cgroup” ]
CMD [“/usr/sbin/init”]

CMD /usr/pgsql-12/bin/postgresql-12-setup initdb
CMD cp /var/lib/pgsql/12/data/pg_hba.conf /var/lib/pgsql/12/data/pg_hba.conf.orig
RUN bash -c 'echo "local all all peer">/var/lib/pgsql/12/data/pg_hba.conf'
RUN bash -c 'echo "host all all 127.0.0.1/32 md5" >>/var/lib/pgsql/12/data/pg_hba.conf'
RUN bash -c 'echo "host all all ::1/128 md5" >>/var/lib/pgsql/12/data/pg_hba.conf'

# start postgresql service
CMD systemctl start postgresql-12
CMD systemctl enable postgresql-12
CMD postgres psql -U postgres -d postgres -c "alter user postgres with password '1rysview';"
CMD systemctl restart postgresql-12

