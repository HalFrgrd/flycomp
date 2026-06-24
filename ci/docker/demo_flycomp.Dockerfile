FROM demo-base AS demo-builder

USER john

# Copy the flycomp binary from build target context
COPY --from=flycomp-extracted-binary /flycomp /home/john/bin/flycomp

COPY ci/tapes/demo_settings.tape .
COPY ci/tapes/demo_setup.tape .
COPY ci/tapes/demo.tape .

# Override PS1 with a minimal prompt for the demo
RUN printf '%s\n' \
    'PS1="\[\e[01;32m\]john@demo\[\e[00m\]:\[\e[01;35m\]\w\[\e[00m\]\$ "' \
    >> /home/john/.bashrc

RUN faketime @1771881894 /home/john/bin/evp demo.tape

FROM scratch
COPY --from=demo-builder /app/*.gif /app/*.svg /
COPY --from=demo-builder /home/john/grep_completion.sh /grep_completion.sh
COPY --from=demo-builder /home/john/rm_completion.json /rm_completion.json
