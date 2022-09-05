#!/usr/bin/env python3

################################################################################
#i  Wait until 
#ii
#ii
#ii Example:
#ii     bash "./src/script/workflow/process_input.sh"
#ii
#ii Inputs:
#ii     env     source_path
#ii     env     test_names
#ii     env     max_test_count
################################################################################


import os
import re
import sys
import trace

from typing import Any, Callable, List


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
    max_test_count: int = int(os.environ["max_test_count"])

    for i in range(min(len(test_names), max_test_count)):
        print(
            test_names[i],
            file=open(f"/root/output/test_name_{i+1:02d}.txt", "w"),
        )

    for i in range(min(len(test_names), max_test_count), max_test_count):
        print(
            "null",
            file=open(f"/root/output/test_name_{i+1:02d}.txt", "w"),
        )

if __name__ == "__main__":
    tracer = trace.Trace(
        count=0,
        trace=1,
        ignoredirs=[sys.prefix, sys.exec_prefix])

    tracer.run("main()")
