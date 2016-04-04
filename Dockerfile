FROM jupyter/notebook

MAINTAINER Saagie

# Installing libraries dependencies
RUN apt-get update && apt-get install -y --no-install-recommends python-numpy python3-numpy libpng3 libfreetype6-dev libatlas-base-dev gfortran libgdal1-dev libjpeg-dev libsasl2-dev unixodbc-dev && apt-get clean && rm -rf /var/lib/apt/lists/* 

# Install python3 libraries
RUN pip3 --no-cache-dir install ipywidgets \
								pandas \
								matplotlib \
								scipy \
								scikit-learn \
								pyodbc \
								impyla \
								hdfs \
								scikit-image \
								bokeh \
								keras \
								pybrain \
								statsmodels \
								mpld3 \
								networkx \
								fiona \
								folium \
								shapely \
								&& rm -rf /root/.cache

# Install python2 libraries
RUN pip2 --no-cache-dir install ipywidgets \
								pandas \
								matplotlib \
								scipy \
								scikit-learn \
								pyodbc \
								impyla \
								bokeh \
								scikit-image \
								pybrain \
								networkx \
								&& rm -rf /root/.cachex

ADD examples-notebook ./Python3-examples
ADD Data ./Data

# Run the notebook
CMD jupyter notebook
    --pylab=inline \
    --ip=* \
    --MappingKernelManager.time_to_dead=10 \
    --MappingKernelManager.first_beat=3 \
    --notebook-dir=/notebooks-dir-python/
