FROM stilliard/pure-ftpd:latest

# Create a directory within the FTP user's home directory
RUN mkdir -p /home/ftpusers

# Set permissions for the directory (if needed)
RUN chown ftpuser:ftpuser /home/ftpusers

# Optionally, you can expose the FTP port (default is 21)
# EXPOSE 21

# Start the FTP server
CMD ["pure-ftpd", "-c", "50", "-C", "10", "-l", "puredb:/etc/pure-ftpd/pureftpd.pdb", "-E", "-j", "-R", "-P", "localhost", "-s"]