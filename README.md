# Reproduce genomic CNN

Attempt to reproduce the results of published neural networks related to genome analysis.
Many published analyses are difficult to reproduce due to differences in environments that the analyses are run on.
This attempts to test publish analyses against multiple explicit environments to determine the necessary packages and version needed.

## Docker

To produce reproducible results, all the tools needed to run the environment tests will be included into a published docker image that can run on any computer.

The tests can then be run using the specified Make targets.
For example, to test Basenji run:

```shell
make basenji
```

The tests that can be run are the docker files under the `docker` directory.
These are named as `${model}.docker` where `${model}` is the name to use with make---`make ${model}`.

By default the model will run a simple example script.
To change the script run use the `SCRIPT` environment variable to specify the path to a different script.
If data is needed, a data directory can also be passed in the `DATA_DIR` environment variable.

For example:

```shell
SCRIPT="$HOME/.local/share/test.py" DATA_DIR="/data/test_data" make basenji
```

To allow the script to find the data, assume the data directory is `/data` inside the container.

> [!NOTE]
> While the data these models are run on would ideally be stored in the containers to ensure reproducibility, to keep container size under control, data is left outside the containers and downloaded as needed. Additionally, this allows external scripts to download data that isn't known at the time of building the container. This could lead to inconsistent results if the data becomes unavailable or is updated.

## Models

### Basenji

```shell
SCRIPT="examples/basset.py" DATA_DIR="data/basenji" make basenji
```

## Project organization

etc/ docker/ vendor/ data/ build/ examples/
