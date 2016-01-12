FROM vikingco/django:2.7
MAINTAINER Jef Geskens

ENV PYTHONUNBUFFERED 1

COPY . ${SRCDIR}
RUN pip install -U pip
RUN pip install -e .

ENV DJANGOROOT ${SRCDIR}/advreport_test_project
ENV WSGIFILE advreport_test_project/wsgi.py
ENV DJANGO_SETTINGS_MODULE advreport_test_project.docker

RUN set -e \
	&& buildDeps=`cat ${SRCDIR}/builddeps.txt` && echo $buildDeps \
	&& requiredAptPackages=`cat ${SRCDIR}/deps.txt` && echo $requiredAptPackages \
	&& apt-get update \
	&& apt-get install -y $buildDeps $requiredAptPackages --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && pip install -r ${SRCDIR}/requirements-docker.txt \
    && pip freeze \
    && find /usr/local \
		\( -type d -a -name test -o -name tests \) \
		-o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
		-exec rm -rf '{}' + \
	&& apt-get purge -y --auto-remove $buildDeps

WORKDIR ${DJANGOROOT}
