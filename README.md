# Jupyter Datascience Notebook for python

## Images 

Jupyter notebook for Python is declined into several images :

    * saagie/jupyter-python-nbk:v2-minimal  
    * saagie/jupyter-python-nbk:v2-base / saagie/jupyter-python-nbk:v2 
    * saagie/jupyter-python-nbk:v2-scipy 

### saagie/jupyter-python-nbk:v2-minimal
This image is based **jupyter/minimal-notebook** one,

=> adapted to run s;loothly on Saagie's platform

=> with no particular datascience additionnal libs it's up toi you to add your owns.

### saagie/jupyter-python-nbk:v2-base
This is the official and main image, base on **jupyter/minimal-notebook** 

=> it comes with a bunch of additional libraries 

=> and is quite similar to **jupyter/scipy-notebook** with even more features.

This image is the same as **saagie/jupyter-python-nbk:v2**

### saagie/jupyter-python-nbk:v2-scipy
This is the legacy @deprecated v2 image, initially based on **jupyter/scipy-notebook** 

=> it comes with a bunch of additional libraries 

=> but is now **deprecated** in favor of ***saagie/jupyter-python-nbk:v2-base***


## Run with :

### Standalone image

	docker run -p 8888:8888 -v /path/to/data/notebooks/dir:/notebooks-dir saagie/jupyter-python-nbk:v2latest

	Mounting volume is optional (-v /path/to/data/notebooks/dir:/notebooks-dir) but if you want to do it:
	* create your local directory with: `mkdir -P /path/to/data/notebooks/dir`
	* make Jovyan (Jupyter notebook default user) the owner of this directory with: `chown -R 1000:100 /path/to/data/notebooks/dir`

### On Saagie's platform 

    * use port 8888
    * define SAAGIE_BASE_PATH env var for base_path
    * do not activate "rewrite url"
    * optionnaly you can add a volume to map /notebooks-dir folder

## Libraries :
	* Data Processing
		* numpy
    	* scipy
		* pandas

	* Machine Learning
    	* sklearn
		* keras
    	* pybrain (python 2 only)
    	* statsmodel
		* networkx

	* Data Visualisation
		* skimage
		* matplotlib
    	* bokeh
    	* mpld3
    	* folium

	* Database connection
		* pyodbc
    	* hdfs **
		* impyla
		* ibis-framework
		* SQLAlchemy
		* pymongo

	* Utils
    	* ipywidgets
		* fiona
 		* shapely

## Install libraries with :
### For python 3
	!pip install libraryName

/!\ Python2 support dropped

