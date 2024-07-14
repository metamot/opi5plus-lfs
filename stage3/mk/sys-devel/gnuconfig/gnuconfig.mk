SRC+= src/config.guess
SRC+= src/config.sub
gnuconfig: src/config.guess src/config.sub
src/config.guess: src/.gitignore
	wget "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess" -O $@
src/config.sub: src/.gitignore
	wget "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub" -O $@
