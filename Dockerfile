FROM remnrem/luna:latest

WORKDIR /build
ENV DEBIAN_FRONTEND=noninteractive

RUN R -e "install.packages('matlab',repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('data.table',repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('argparse',repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('dplyr',repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('tidyr',repos='http://cran.rstudio.com/')"

RUN cd /build \
 && git clone https://github.com/mazzottidr/nsrr_luna_mazzotti.git
 
RUN chmod +x /build/nsrr_luna_mazzotti/mazzotti_tools/luna_find_channels.sh

RUN chmod +x /build/nsrr_luna_mazzotti/mazzotti_tools/luna_validate_edf.sh

CMD [ "/bin/bash" ]

