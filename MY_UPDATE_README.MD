Check instructions in: https://github.com/gekkekoe/esphome-ecodan-hp/blob/main/docs/build-from-source.md but in short, this should be enough:

Sync this fork with the original repo:

```
git fetch upstream
git checkout main 
git merge upstream/main
```

If not using bash, you might have to do that for python:

```
bash
```

Activate the python environment:

```
python3 -m venv venv
source venv/bin/activate
pip3 install wheel
pip3 install esphome


source venv/bin/activate
```

Build the firmware:

```
esphome compile ecodan-esphome.yaml
```

Upload/deploy the firmware over the network:
``` 
esphome upload --device x.x.x.x ecodan-esphome.yaml
```

Secrets will be used from the secrets.yaml file in the root, not comitted.