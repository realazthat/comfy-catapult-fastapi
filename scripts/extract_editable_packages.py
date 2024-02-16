"""Find all editable packages in the current environment.
"""

import json
import subprocess
import sys

cmd = ["pip3", "list", "--format=json", "-v"]

p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=sys.stderr)
if p.returncode != 0:
  raise Exception(f"pip3 list failed with return code {p.returncode}")

json_str = p.stdout.decode("utf-8")

package_infos = json.loads(json_str)

relevant_package_infos = []
for package_info in package_infos:
  if package_info['installer'] != '':
    continue
  relevant_package_infos.append(package_info)
print(json.dumps(relevant_package_infos, indent=2))
