# exit on command failure
set -e

# Compile all the coffeescript files
coffee -o dist/lib -c lib
coffee -o dist -c server.coffee
