FROM rockylinux:9

# Set environment variables
ENV FLASK_APP=src/app.py \
    FLASK_ENV=development \
    FLASK_DEBUG=true

# Install dependencies in a single layer to reduce image size
RUN dnf install -y sudo python3 epel-release pip net-tools bind-utils && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Create user with specific UID/GID
RUN groupadd shoutsky -g 1333 && \
    adduser shoutsky -u 1333 -g 1333 && \
    echo "shoutsky ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/shoutsky && \
    chmod 0440 /etc/sudoers.d/shoutsky && \
    mkdir -p /usr/local/src/shoutsky && \
    chown -R shoutsky:shoutsky /usr/local/src/shoutsky

# Set working directory
WORKDIR /usr/local/src/shoutsky

# Copy requirements first to leverage Docker cache
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy the rest of the application
COPY --chown=shoutsky:shoutsky . .

# Switch to non-root user
USER shoutsky

# Run the application
CMD ["python3", "-m", "flask", "run", "--host=0.0.0.0"]