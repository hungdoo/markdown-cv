# Example script to generate HTML and push to local gh-pages directory.
REMOTE_USER=$1
REMOTE_SERVER=$2

function print_help () {
  echo "Run ./publish.sh <remote_user> <server_url>"
  exit 1
}

[ -z ${REMOTE_USER} ] && { echo 'Missing user info'; print_help; }
[ -z ${REMOTE_SERVER} ] && { echo 'Missing server info'; print_help; }

# build site from markdown
docker run --rm -v $(pwd):/src -w /src jekyll/jekyll:latest jekyll build

# # deploy to webserver
echo ""
echo "-------"
echo "Deploy to: ${REMOTE_USER}@${REMOTE_SERVER}"
scp -r _site/ ${REMOTE_USER}@${REMOTE_SERVER}:/home/${REMOTE_USER}
# # Volumes from container
ssh ${REMOTE_USER}@${REMOTE_SERVER} 'docker run --rm --volumes-from nginx_website \
  -v /home/'"${REMOTE_USER}"'/_site:/src alpine:latest /bin/sh -c \
  "cp -r /src/index.html /src/media /src/fonts /usr/share/nginx/html/" && \
  rm -rf /home/'"${REMOTE_USER}"'/_site'
