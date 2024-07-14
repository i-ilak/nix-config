import os
import re

from typing import TypedDict, Optional


MATCH_PATTERN_DEFAULT = r"""vim\.keymap\.set\(\".*?\",\s\"([^\"]+)\",.*,?.*\)\s*--\s*([^\"]+)\n"""


class ParseResult(TypedDict):
    shortcut: str
    description: str

def parse_line(line: str) -> Optional[ParseResult]:
    if "set" in line:
        matches = re.search(MATCH_PATTERN_DEFAULT, line)
        if not matches:
            return None
        return {"shortcut": matches.group(1), "description": matches.group(2)}


if __name__ == "__main__":
    base_path = os.path.join(os.getenv("HOME"), ".config/nvim/")
    file_mappings = os.path.join(base_path, "lua/mappings.lua")
    file_cheatsheet = os.path.join(base_path, "cheatsheet.txt")

    with open(file_mappings) as f:
        lines = f.readlines()
    
    lines_to_write = []

    for line in lines:
        result = parse_line(line)
        if result:
            lines_to_write.append(result)

    with open(file_cheatsheet, "w") as cheatsheet:
        for line in lines_to_write:
            cheatsheet.write(f"{line["description"]} | {line["shortcut"]}\n")

