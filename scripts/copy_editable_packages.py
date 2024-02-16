"""Copy editable packages into a specified directory.
"""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import fnmatch
from typing import List

parser = argparse.ArgumentParser(description=__doc__)

parser.add_argument(
    "--package_infos",
    type=str,
    help="The package infos to copy (json). See extract_editable_packages.py.")
parser.add_argument("--output_dir",
                    type=Path,
                    help="The directory to copy the packages to.")
args = parser.parse_args()


def is_mounted(path: Path) -> bool:
  path = path.resolve()
  p = subprocess.run(
      ["findmnt", "--noheadings", "--output", "SOURCE",
       str(path)],
      stdout=subprocess.PIPE,
      stderr=subprocess.PIPE)
  if p.returncode != 0:
    raise Exception(f"findmnt failed with return code {p.returncode}")

  return p.stdout.strip() != b""


def unmount(path: Path) -> None:
  path = path.resolve()
  p = subprocess.run(["fusermount", "-u", str(path)],
                     stdout=sys.stderr,
                     stderr=sys.stderr)
  if p.returncode != 0:
    raise Exception(f"fusermount failed with return code {p.returncode}")


def mount(source: Path, target: Path) -> None:
  p = subprocess.run(
      ["bindfs", "--perms=a-w",
       str(source), str(target)],
      stdout=sys.stderr,
      stderr=sys.stderr)
  if p.returncode != 0:
    raise Exception(f"bindfs failed with return code {p.returncode}")


def parse_gitignore(gitignore_path) -> List[str]:
  """Parse .gitignore and return a list of patterns to ignore."""
  patterns = []
  with open(gitignore_path, 'r') as file:
    for line in file:
      stripped_line = line.strip()
      if stripped_line and not stripped_line.startswith('#'):
        patterns.append(stripped_line)
  return patterns


def should_ignore(*, rel_path: Path, ignore_patterns: List[str]):
  """Determine if the path matches any of the ignore patterns."""

  for pattern in ignore_patterns:
    match = fnmatch.fnmatch(str(rel_path), pattern)
    if match:
      return True
  return False


def gitignore_ignore(src: Path, names, *, ignore_patterns: List[str],
                     package_path: Path):
  """Custom ignore function for shutil.copytree."""
  ignored_names = []
  for name in names:
    path = Path(os.path.join(src, name))
    rel_path = path.relative_to(package_path)
    if should_ignore(rel_path=rel_path, ignore_patterns=ignore_patterns):
      ignored_names.append(name)
  return set(ignored_names)


package_infos = json.loads(args.package_infos)

for package_info in package_infos:
  package_name = package_info['name']
  package_version = package_info['version']
  package_location = package_info['location']

  package_path = Path(package_location)
  package_path = package_path.resolve()

  output_package_path = args.output_dir / f"{package_name}"
  output_package_path = output_package_path.resolve()

  ##############################################################################
  # output_package_path.hardlink_to(package_path)
  ##############################################################################
  # if output_package_path.exists():
  #   if is_mounted(output_package_path):
  #     unmount(output_package_path)
  #   shutil.rmtree(output_package_path)
  # output_package_path.mkdir(parents=True, exist_ok=True)
  # mount(package_path, output_package_path)
  ##############################################################################
  if output_package_path.exists():
    shutil.rmtree(output_package_path)

  gitignore_path = package_path / ".gitignore"
  ignore_patterns = ['.*']
  if gitignore_path.exists():
    ignore_patterns += parse_gitignore(gitignore_path)

  print('ignore_patterns:', ignore_patterns)

  # output_package_path.mkdir(parents=True, exist_ok=True)
  shutil.copytree(package_path,
                  output_package_path,
                  ignore=lambda src, names: gitignore_ignore(
                      src,
                      names,
                      ignore_patterns=ignore_patterns,
                      package_path=package_path))
  ##############################################################################
