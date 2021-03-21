FROM centos:6

LABEL maintainer Grant van Riessen <g.vanriessen@latrobe.edu.au>

RUN curl https://www.getpagespeed.com/files/centos6-eol.repo --output /etc/yum.repos.d/CentOS-Base.repo \
    && yum -y  update \
    && yum groupinstall -y "development tools" \
    && yum install -y zlib-devel \
                      bzip2-devel \
                      openssl-devel \
                      ncurses-devel \
                      sqlite-devel \
                      readline-devel \
                      tk-devel \
                      gdbm-devel \
                      db4-devel \
                      libpcap-devel \
                      xz-devel \
                      expat-devel \
                      wget \
                      openmpi-devel \
    && wget http://python.org/ftp/python/3.6.3/Python-3.6.3.tar.xz \
    && tar xf Python-3.6.3.tar.xz \
    && rm Python-3.6.3.tar.xz \
    && cd Python-3.6.3 \
    && ./configure --enable-optimizations --enable-shared --disable-test-suite\
    && make -j8 build_all \
    && make -j8 altinstall


ENV LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib
ENV CC=/usr/lib64/openmpi/bin/mpicc


# Set up and activate virtual environment
ENV VIRTUAL_ENV=/opt/venv
RUN /usr/local/bin/python3.6 -m venv $VIRTUAL_ENV
ENV PATH "$VIRTUAL_ENV/bin:$PATH"
# continue installation with venv


COPY requirements.txt requirements.txt
RUN wget https://bootstrap.pypa.io/get-pip.py \
    && python get-pip.py \ 
    && rm get-pip.py \
    && pip install -r requirements.txt \
    && rm requirements.txt 

WORKDIR /opt
RUN git clone --depth 1 --branch deploy https://github.com/GVRX/SRW.git SRW \
    && cd /opt/SRW \
    && export MODE=omp \
    && make all MODE=omp \
    && cd /opt/SRW/cpp/py \
    && make clean ; make \ 
    && python setup.py develop

WORKDIR /opt
RUN wget https://github.com/samoylv/WPG/archive/19.12.tar.gz \
    && tar -zxf 19.12.tar.gz \
    && rm 19.12.tar.gz \
    && ln -s /opt/WPG-19.12 /opt/WPG \
    && rm -rf /opt/WPG/srw \
    && rm -rf /opt/WPG/srwlib.py \
    && mv /opt/WPG/wpg/__init__.py /opt/WPG/wpg/__init__.bak \
    && > /opt/WPG/wpg/__init__.py 

# make wpg a package, with direct dependence on srw location removed
WORKDIR /opt/WPG
RUN echo -e "import os \nfrom  setuptools import setup \nsetup(name='wpg',packages=['wpg'])" > setup.py \
    && python setup.py develop

#VOLUME /data
#WORKDIR ~/data

# for testing:
#ENV PYTHONPATH=/opt/WPG:$PYTHONPATH
#ENV PYTHONPATH=/opt/SRW:$PYTHONPATH
#ENV PYTHONPATH=/opt/SRW/env/work/srw_python
ENV PYTHONPATH=/opt/xrnl:/opt/SRW/env/work/srw_python:/opt/xl/xl

WORKDIR /opt/xl

#RUN cd /opt/WPG && python -m pytest .

# for Jupyter notebook
#EXPOSE 8888
#CMD jupyter notebook --no-browser --ip 0.0.0.0 --notebook-dir /
