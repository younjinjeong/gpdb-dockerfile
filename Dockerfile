FROM pivotaldata/gpdb-devel

WORKDIR /workspace

ADD . gpdb/

WORKDIR gpdb

# Install Package 
# RUN yum -y clean all
RUN yum -y install wget git cmake3 python34
# Change Default Python Version from 2.6 to 3.4 
RUN mv /usr/bin/python /usr/bin/python-old ; rm -fR /usr/bin/pip* 
RUN mv /usr/bin/python3.4 /usr/bin/python

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python get-pip.py
RUN pip install tensorflow && pip install keras && pip install h5py 
#RUN python -m venv venv && source venv/bin/activate && pip install --upgrade pip && pip install tensorflow && pip install keras && pip install h5py 


# Install Ninja
RUN mkdir -p /workspace/ninja ; cd /workspace/ninja
RUN wget https://github.com/ninja-build/ninja/releases/download/v1.8.2/ninja-linux.zip ; unzip ninja-linux.zip ; cp ninja /usr/bin/ ; cp ninja /usr/local/bin/ 

# Install gp-xerces
RUN cd /workspace
RUN git clone https://github.com/greenplum-db/gp-xerces ; cd gp-xerces ; mkdir build ; cd build ; ../configure --prefix=/usr/local && make -j4 && make install

# Install gpos
RUN cd /workspace
RUN git clone https://github.com/greenplum-db/gpos ; cd gpos ; mkdir build ; cd build ; cmake ../ && make -j4 && make install 

# Install GPORCA
RUN cd /workspace
RUN git clone https://github.com/greenplum-db/gporca && cd gporca ; git checkout tags/v2.64.0 ; mkdir build ; cd build ; cmake3 .. && make  && make install 

RUN cd /workspace
RUN echo "/usr/local/lib" >> /etc/ld.so.conf && echo "/usr/local/gpdb/lib" >> /etc/ld.so.conf
RUN /sbin/ldconfig -f /etc/ld.so.conf

# Remove Original GPDB 
RUN rm -fR /workspace/gpdb 

# Configure && install GPDB 
RUN cd /workspace
RUN git clone https://github.com/greenplum-db/gpdb 

ADD . gpdb/
WORKDIR gpdb

RUN ./configure --with-python --with-perl --enable-mapreduce --with-python --with-libxml --prefix=/usr/local/gpdb --disable-gpcloud
RUN time make -j4
RUN make install

RUN chown -R gpadmin:gpadmin /workspace/gpdb
RUN chown -R gpadmin:gpadmin /usr/local/gpdb
