FROM continuumio/miniconda3:latest

RUN apt-get update && apt-get install gcc -y

RUN --mount=type=bind,source=vendor/basenji/prespecified.yml,target=/tmp/prespecified.yml \
    conda env create --file=/tmp/prespecified.yml

RUN echo "conda activate basenji" >> "$HOME"/.bashrc

COPY vendor/basenji /tmp/basenji

# Don't know why I have to install it like this. Using a mount and `pip
# install` installs it in the correct conda env but when importing python can't
# find it. It only gets imported if stored locally and installed in editable
# mode.
RUN . "$HOME"/.bashrc && \
    pip install --editable /tmp/basenji

COPY --chmod=777 etc/basenji/call_script.sh /bin

CMD ["/bin/bash", "-c", ". $HOME/.bashrc && /bin/call_script.sh"]
