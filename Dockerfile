# https://github.com/rocker-org/rocker-versioned/blob/master/r-ver/3.6.0.Dockerfile
FROM rocker/r-ver:3.6.0

RUN install2.r here

WORKDIR /my-analysis
COPY workflow.R workflow.R

VOLUME /data

LABEL org.label-schema.license="GPL-2.0" \
      org.label-schema.vcs-url="https://github.com/nuest/container-image-for-librarians-101" \
      org.label-schema.vendor="Daniel Nüst" \
      maintainer="Daniel Nüst <daniel.nuest@uni-muenster.de>"

CMD Rscript /my-analysis/workflow.R

# run this file with
# docker run --rm -it --volume $(pwd)/data:/data cifl101
