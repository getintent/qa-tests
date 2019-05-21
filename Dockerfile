FROM python:3.7-alpine3.9

ENV SCREEN_WIDTH 1920
ENV SCREEN_HEIGHT 1080
ENV SCREEN_DEPTH 16
ENV BROWSER chrome
ENV PROCESSES 1
ENV MAX_RERUNS 5
ENV DEPS="\
    chromium \
    chromium-chromedriver \
    udev \
    xvfb \
    bash \
"
ENV REQS="\
    robotframework==3.1.1 \
    robotframework-seleniumlibrary==3.3.1 \
    selenium==3.141.0 \
    robotframework-pabot==0.53 \
    robotframework-jsonvalidator=1.0.1
"

COPY entry_point.sh /opt/bin/entry_point.sh

RUN apk update ;\
    apk add --no-cache ${DEPS} ;\
    pip install --no-cache-dir ${REQS} ;\
    # Chrome requires docker to have cap_add: SYS_ADMIN if sandbox is on.
    # Disabling sandbox and gpu as default.
    sed -i "s/self._arguments\ =\ \[\]/self._arguments\ =\ \['--no-sandbox',\ '--disable-gpu'\]/" $(python -c "import site; print(site.getsitepackages()[0])")/selenium/webdriver/chrome/options.py ;\
    # List packages and python modules installed
    apk info -vv | sort ;\
    pip freeze ;\
    # Cleanup
    rm -rf /var/cache/apk/* /tmp/requirements.txt

CMD [ "/opt/bin/entry_point.sh" ]
