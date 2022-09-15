#!/usr/bin/env python3

################################################################################
#i  Process workflow input so it can be used by the tasks.
#ii
#ii
#ii Example:
#ii     python "./src/script/workflow/process_input.py"
#ii
#ii Inputs:
#ii     env     source_path
#ii     env     test_names
################################################################################


import json
import os
import re
import sys

from functools import partial
from typing import Any, Callable, Dict, List


def pipe(data: Any, *funcs: Callable[..., Any]) -> Any:
    for func in funcs:
        data = func(data)
    return data


def main() -> None:
    print(sys.executable)

    os.chdir(os.environ["source_path"])
    os.system("""pwd""")
    os.system("""mkdir -p "/root/output/" """)

    ############################################################################

    test_names: List[str] = pipe(
        os.environ["test_names"],
        lambda _: re.sub(r"[^a-z0-9_]", " ", _),
        lambda _: re.sub(r"\s+", " ", _),
        lambda _: _.strip(),
        lambda _: re.split(" ", _),
    )

    tests: List[Dict[str, str]] = pipe(
        test_names,
        enumerate,
        partial(
            map,
            lambda i_n: {"test_key": i_n[0] + 1, "test_name": i_n[1]}),
        list,
    )

    print(
        json.dumps(tests),
            file=open(f"/root/output/tests.txt", "w"))

if __name__ == "__main__":
    main()
