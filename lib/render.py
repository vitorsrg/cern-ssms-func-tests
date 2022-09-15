#!/usr/bin/env python3

################################################################################
#i  ...
#ii
#ii
#ii Example:
#ii     python "./lib/render.py" \
#ii         -D "gitlab_token" "gitlab_token" \
#ii         -D "gitlab_url" "gitlab_url" \
#ii         -D "source_path" "source_path" \
#ii         "./func_test/k8s_eos/pod.yml.jinja"
################################################################################


import argparse
import jinja2
import sys

from typing import Dict, Optional


def main(
    relpath: Optional[str] = None,
    vars: Optional[Dict[str, str]] = None,
) -> None:
    """"""

    template = (
        sys.stdin.read()
        if relpath is None or relpath == "-"
        else open(relpath).read()
    )
    env = jinja2.Environment(
        loader=jinja2.FileSystemLoader("."),
        keep_trailing_newline=True,
    )
    res = (
        env
        .from_string(template)
        .render(vars or {})
    )

    print(
        res,
        end="",
    )


def _parse_args() -> argparse.ArgumentParser:
    """"""

    parser = argparse.ArgumentParser(
        # prog="./lib/render.py",
        # description="""""",
        add_help=True,
    )

    parser.add_argument(
        "-D", "--define",
        action="append",
        nargs=2,
        type=str,
        metavar=("key", "value"),
        help="define data with key-value pairs",
    )
    parser.add_argument(
        "template",
        default=None,
        nargs="?",
        type=str,
        metavar="template",
        help="template file",
    )

    args = parser.parse_args()

    return args

if __name__ == "__main__":
    args = _parse_args()

    main(
        relpath=args.template,
        vars=dict(args.define or []),
    )
