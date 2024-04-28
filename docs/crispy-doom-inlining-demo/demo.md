# Crispy Doom In-Lining for Size
NOTE: this demo assumes that you are building on Linux. The instructions for building crispy doom change for Windows / MacOS and may introduce unforseen issues.

## Preliminaries
We assume all repositories are installed under `$HOME`, e.g. you should have
(after the next step) a `~/crispy-doom`, `~/opti-ml`, etc.

## Repositories

### Opti-ML
If you do not already have it, clone this repostiry
```shell
cd ~ && git clone git@github.com:TrainingAfternoon/opti-ml.git
```

Create a venv where you can install all of the required packages
```shell
virtualenv optiml
source optiml/bin/activate
pip install pipenv
pipenv install
deactivate
```

### LLVM

Follow the instructions available at https://llvm.org/docs/GettingStarted.html.
In most cases, it should be as simple as:

```shell
cd ~ && git clone https://github.com/llvm/llvm-project.git
```

LLVM can be built by running
```shell
./build_llvm.sh
```
in the project source.

### Crispy Doom
```shell
cd ~ && git clone git@github.com:fabiangreffrath/crispy-doom.git
```

To build crispy doom you need to generate the makefiles using their [Linux build instructions](https://github.com/fabiangreffrath/crispy-doom/wiki/Building-on-Linux)
```shell
sudo apt install build-essential automake git
sudo apt build-dep crispy-doom
cd crispy-doom
autoreconf -fiv
./configure
```

From any of the `Makefile`s in crispy-doom you need to extract the CFLAGS environment variable and paste it into `make_crispy_doom.sh` as the contents of the `CFLAGS` variable. Once you've done this you can run
```shell
./make_crispy_doom.sh
```
to build crispy doom, assuming you've built LLVM + clang at this point.

You will also need a doom WAD file if you want to run the application.
```shell
wget http://cdn.debian.net/debian/pool/non-free/d/doom-wad-shareware/doom-wad-shareware_1.9.fixed.orig.tar.gz

gunzip doom-wad-shareware_1.9.fixed.orig.tar.gz
tar xvf doom-wad-shareware_1.9.fixed.orig.tar

mv doom-wad-shareware_1.9.fixed.orig/doom1.wad ~/crispy-doom
```

## Running the Training Pipeline
Don't forget to have compiled crispy doom!
```shell
./extract_corpus.sh
./generate_trace.sh
./train_warmstart_model.sh
./train_new_model.sh
```
