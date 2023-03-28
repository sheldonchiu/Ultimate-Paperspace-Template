#!/bin/bash
cd /storage/stable-diffusion/stable-diffusion-webui

#!/bin/bash

x_arg=""
if [ -n "${ACTIVATE_XFORMERS}" ]; then
  x_arg="--xformers"
fi

mvram_arg=""
if [ -n "${ACTIVATE_MEDVRAM}" ]; then
  mvram_arg="--medvram"
fi

pickled=""
if [ -n "${DISABLE_PICKLE_CHECK}" ]; then
  pickled="--disable-safe-unpickle"
fi

port="--share"
if [ -n "${GRADIO_PORT}" ]; then
  port="--port ${GRADIO_PORT}"
fi

auth=""
if [ -n "${GRADIO_AUTH}" ]; then
  auth="--gradio-auth ${GRADIO_AUTH} --enable-insecure-extension-access"
fi

theme=""
if [ -n "${UI_THEME}" ]; then
  theme="--theme ${UI_THEME}"
fi

insecure_extension_access=""
if [ -n "${ENABLE_INSECURE_EXTENSION_ACCESS}" ]; then
  insecure_extension_access="--enable-insecure-extension-access"
fi

queue=""
if [ -n "${GRADIO_QUEUE}" ]; then
  queue="--gradio-queue"
fi

python webui.py ${x_arg} ${dd_arg} ${mvram_arg} ${pickled} ${port} ${auth} ${theme} ${insecure_extension_access} ${queue}