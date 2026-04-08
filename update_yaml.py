#!/bin/env python3

import sys
from warnings import warn
from io import StringIO, SEEK_END
from pathlib import Path

from yaml import safe_load, safe_dump

def read_yaml(file: str | Path) -> StringIO:
    """Parses and reads a yaml file with optional scheme versioning

    It will return a stream of the content of the file.
    Since the Miniforge3 `construct.yaml` file contains Jinja2 templates
    we cannot parse it using PyYaml or other tools.

    Therefore this reads it *as is*, then a subsequent key-edit change will
    be done.
    """
    yaml = StringIO()
    yaml.write(open(file, 'r').read())
    yaml.seek(0)
    return yaml


def replace_key(stream: StringIO, key: str, value: str) -> StringIO:
    """Replaces a key in the stream if found """
    out = type(stream)()

    key_s = f"{key}:"
    found = False

    for line in stream:
        if line.startswith(key_s):
            out.write(": ".join([key, str(value)]) + "\n")
            found = True
        else:
            out.write(line)

    if not found:
        raise Exception(f"Could not find {key=}")
    out.seek(0)
    return out


def replace_list_element(stream: StringIO, key: str, element_start: str, value: str) -> StringIO:
    out = type(stream)()

    key_s = f"{key}:"
    found = False

    stream_iter = iter(stream)
    while True:
        try:
            line = next(stream_iter)
        except StopIteration:
            break
        out.write(line)
        if line.startswith(key_s):
            # Since we are in a list, we don't expect it
            # to be the last, it's not elegant.
            list_elem = next(stream_iter)
            indent = "  " # default indentation for list specifications
            while list_elem.strip().startswith(("- ", "# ")):
                indent, element_value = list_elem.split("-", maxsplit=1)
                if element_value.strip().startswith(element_start):
                    found = True
                    out.write("".join([indent, "- ", value, "\n"]))
                else:
                    out.write(list_elem)
                list_elem = next(stream_iter)
            if not found:
                # add it
                out.write("".join([indent, "- ", value, "\n"]))
                warn(f"Adding element[{element_start}] to list {key}")
                found = True

            out.write(list_elem)

    if not found:
        raise Exception(f"Could not find {key=}")

    out.seek(0)
    return out


def has_key(stream: StringIO, key:str) -> bool:
    """Checks if a key exists in the yaml file """
    key_s= f"{key}:"
    found =False

    for line in stream:
        if line.startswith(key_s):
            found = True
            break

    stream.seek(0)
    return found


# Do actual parsing and creation of the new constructor recipe.
# This is hard-coded because it'll always be this one
yaml_stream = StringIO()

# Parse the yaml file with the data that is specific for DTU
dtu_values = safe_load(open("dtu_constructor.yaml", 'r'))

# Add new Jinja keys
yaml_stream.write(f"# DTU defined Jinja-variables\n")
for variable, value in dtu_values.pop("dtu_jinja_variables").items():
    yaml_stream.write(f"{{% set {variable} = \"{value!s}\" %}}\n")
yaml_stream.write("\n")

yaml_stream.write(
        read_yaml("miniforge/Miniforge3/construct.yaml")
        .getvalue()
        )
yaml_stream.seek(0)

# Start by replacing the Python version
yaml_stream = replace_list_element(yaml_stream, "specs", "python",
                                   dtu_values["dtu_python"])


# Pop out the specification for the version
# We know of these two we should replace
for key in ("specs", "user_requested_specs"):
    packages = dtu_values.pop(key)
    for element in packages:
        element_start, *_ = element.split(" ", maxsplit=1)
        yaml_stream = replace_list_element(yaml_stream, key, element_start, element)

for key in ("name", "company", "initialize_by_default"):
    yaml_stream = replace_key(yaml_stream, key, dtu_values.pop(key))

# The `dtu_` prefixed keys should be popped as they are only used for
# version specifications.
for key in list(dtu_values.keys()):

# Check that there are no new keys!
for key in list(dtu_values.keys()):
    if key.startswith("dtu_"):
        dtu_values.pop(key)
        continue

    # Check the key does not exist in the *other* yaml
    # file.
    if has_key(yaml_stream, key):
        raise NotImplementedError(f"Found the {key=}, but did not expect it!")

# jump to the end
yaml_stream.seek(0, SEEK_END)
yaml_stream.write("\n")
yaml_stream.write("# DTU specific settings\n")
safe_dump(dtu_values, yaml_stream)

if len(sys.argv) > 1:
    out = sys.argv[1]
else:
    out = "constructor.yaml"
open(out, 'w').write(yaml_stream.getvalue())
