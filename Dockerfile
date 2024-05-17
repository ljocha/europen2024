FROM cerit.io/ljocha/gromacs:2023-2-plumed-2-9-afed-pytorch-model-cv as gmx
FROM quay.io/jupyter/base-notebook


USER 0
RUN apt update \
&& apt install -y gcc \
&& apt install -y mpich \
&& apt install -y libcufft10 libmpich12 libblas3 libgomp1 \
&& apt install -y rsync \
&& apt install -y curl git \
&& apt install -y sassc \
&& apt clean  \
&& rm -rf /var/lib/apt/lists/*

RUN pip install nglview mdtraj 

RUN cd /tmp && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && install -m 755 kubectl /opt/conda/bin


COPY --from=gmx /build/libtorch /build/libtorch
ENV LD_LIBRARY_PATH=/build/libtorch/lib:$LD_LIBRARY_PATH
ENV CPLUS_INCLUDE_PATH=/build/libtorch/include:$CPLUS_INCLUDE_PATH

COPY --from=gmx /build/libtorch/lib/* /usr/local/lib/
COPY --from=gmx /usr/local/bin /usr/local/bin
COPY --from=gmx /usr/local/lib/libplumed* /usr/local/lib/
COPY --from=gmx /usr/local/lib/plumed/ /usr/local/lib/plumed/
COPY --from=gmx /usr/local/cuda/ /usr/local/cuda/
COPY --from=gmx /etc/ld.so.conf.d/000_cuda.conf /etc/ld.so.conf.d/

COPY --from=gmx /gromacs /gromacs

RUN ldconfig

RUN pip install jupyterlab_rise

# ENV css=/opt/conda/lib/python3.11/site-packages/rise/static/reveal.js/css/theme
#ENV css=/opt/conda/share/jupyter/nbextensions/rise/reveal.js/css/theme
# COPY ljocha.scss ${css}/source
# RUN cd ${css} && sassc source/ljocha.scss solarized.css
#RUN cd ${css}/source && cp solarized.scss ljocha.scss

RUN apt update && apt install -y strace && apt clean && rm -rf /var/lib/apt/lists/*

USER ${NB_USER}

RUN cd /tmp && git clone --single-branch -b k8s https://github.com/ljocha/GromacsWrapper.git && pip install ./GromacsWrapper && rm -rf GromacsWrapper

#RUN cd /tmp && git clone --branch v0.42.0 https://github.com/jupyterlab-contrib/rise.git 
#RUN cd /tmp/rise && pip install -e ".[test]" && jupyter labextension develop . --overwrite
#RUN jupyter server extension enable jupyterlab_rise
#RUN cd /tmp/rise && jlpm build

RUN mkdir -p ${HOME}/.jupyter/custom
COPY custom.css ${HOME}/.jupyter/custom
