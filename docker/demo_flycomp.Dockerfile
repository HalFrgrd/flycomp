FROM demo-base AS demo-builder

USER john

# Copy the flycomp binary from build target context
COPY --from=flycomp-extracted-binary /flycomp /home/john/bin/flycomp

COPY tapes/demo_settings.tape .
COPY tapes/demo_setup.tape .
COPY tapes/demo.tape .

# Override PS1 with a minimal prompt for the demo
RUN printf '%s\n' \
    'PS1="john@demo:\w\$ "' \
    >> /home/john/.bashrc

RUN faketime @1771881894 /home/john/bin/evp demo.tape

FROM scratch
COPY --from=demo-builder /app/*.gif /app/*.svg /
