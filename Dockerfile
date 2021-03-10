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
                      wget 

RUN wget http://python.org/ftp/python/3.6.3/Python-3.6.3.tar.xz \
    && tar xf Python-3.6.3.tar.xz \
    && rm Python-3.6.3.tar.xz \
    && cd Python-3.6.3 \
    && ./configure --enable-optimizations --enable-shared --disable-test-suite\
    && make -j8 build_all \
    && make -j8 altinstall


ENV LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib


# Set up and activate virtual environment
ENV VIRTUAL_ENV=/opt/venv
RUN /usr/local/bin/python3.6 -m venv $VIRTUAL_ENV
ENV PATH "$VIRTUAL_ENV/bin:$PATH"


# continue installation with venv
WORKDIR /opt
RUN wget https://bootstrap.pypa.io/get-pip.py \
    && python get-pip.py \ 
    && pip install mock \ 
                      numpy \
                      setuptools \
                      pytest \
                      matplotlib \ 
                      h5py \
                      jupyter \
                      pytest-profiling \
                      autopep8 \
                      requests \
    && rm get-pip.py

WORKDIR /opt
RUN wget https://github.com/samoylv/WPG/archive/19.12.tar.gz \
    && tar -zxf 19.12.tar.gz \
    && rm 19.12.tar.gz \
    && ln -s /opt/WPG-19.12 /opt/WPG \
    && rm -rf /opt/WPG/srw \
    && rm -rf /opt/WPG/srwlib.py \
    && > WPG/wpg/__init__.py \
    && ln -s /opt/SRW/env/work/srw_python /opt/WPG/srw \
    && git clone --depth 1 --branch deploy https://github.com/GVRX/SRW.git SRW \
    && cd /opt/SRW \
    && make all MODE=omp \
    && mkdir -p /opt/SRW/lib \ 
    && cp /opt/SRW/cpp/gcc/srwlpy*.so /opt/SRW/lib/ \
    && cp /opt/SRW/cpp/gcc/srwlpy*.so /opt/SRW/env/work/srw_python \
    && ln -s /opt/SRW/env/work/srw_python /opt/SRW/python
    

# make wpg a package, with direct dependence on srw removed
WORKDIR /opt/WPG
RUN echo -e "import os \nfrom  setuptools import setup \nsetup(packages=['wpg', 'srw'])" > setup.py \
    && python setup.py install

#VOLUME /data
#WORKDIR ~/data

# for testing:
ENV PYTHONPATH=/opt/WPG:$PYTHONPATH
ENV PYTHONPATH=/opt/SRW:$PYTHONPATH

#RUN cd /opt/WPG && python -m pytest .

# for Jupyter notebook
#EXPOSE 8888
#CMD jupyter notebook --no-browser --ip 0.0.0.0 --notebook-dir /

