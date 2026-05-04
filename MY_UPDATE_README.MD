Check instructions in: https://github.com/gekkekoe/esphome-ecodan-hp/blob/main/docs/build-from-source.md but in short, this should be enough:

Sync this fork with the original repo:

```
git remote add upstream https://github.com/gekkekoe/esphome-ecodan-hp.git 
git merge upstream/main

git fetch upstream
git checkout main 
git merge upstream/main
```
Resolve potentional merge conflicts and commit.s

If not using bash, you might have to do that for python:

```
bash
```

Activate the python environment and install/update depedencies:

```
python3 -m venv venv
source venv/bin/activate
pip3 install wheel (or update with python3 -m pip install --upgrade wheel)
pip3 install esphome  (or update with python3 -m pip install --upgrade esphome)
```

Build the firmware:

```
esphome compile ecodan-esphome.yaml
```

Upload/deploy the firmware over the local network:
``` 
esphome upload --device x.x.x.x ecodan-esphome.yaml
```

Secrets will be used from the secrets.yaml file, not comitted.