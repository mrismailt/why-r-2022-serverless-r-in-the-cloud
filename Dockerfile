FROM rocker/tidyverse:latest

RUN R -e "install.packages(c('aws.s3', 'box', 'dotenv', 'logger'))"

COPY script.R /
COPY .env /

CMD Rscript /script.R