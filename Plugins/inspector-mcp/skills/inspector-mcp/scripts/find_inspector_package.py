#!/usr/bin/env python3
import argparse
import subprocess
import sys
from pathlib import Path


def parse_args():
    parser = argparse.ArgumentParser(
        description="Locate the Inspector Swift package for a consumer Xcode project."
    )
    location = parser.add_mutually_exclusive_group(required=True)
    location.add_argument("--xcodeproj")
    location.add_argument("--workspace")
    parser.add_argument("--scheme", required=True)
    return parser.parse_args()


def show_build_settings(args):
    command = ["xcodebuild"]
    if args.xcodeproj:
        command += ["-project", args.xcodeproj]
    else:
        command += ["-workspace", args.workspace]
    command += ["-scheme", args.scheme, "-destination", "generic/platform=iOS Simulator", "-showBuildSettings"]

    result = subprocess.run(
        command,
        check=True,
        capture_output=True,
        text=True,
    )
    return result.stdout


def extract_setting(output, name):
    prefix = f"{name} = "
    for line in output.splitlines():
        stripped = line.strip()
        if stripped.startswith(prefix):
            return stripped[len(prefix):]
    return None


def derived_data_root(build_dir):
    path = Path(build_dir).expanduser().resolve()
    # BUILD_DIR is typically <DerivedData>/<slug>/Build/Products
    if len(path.parents) < 2:
        raise RuntimeError(f"Unexpected BUILD_DIR layout: {path}")
    return path.parents[1]


def main():
    args = parse_args()
    output = show_build_settings(args)

    build_dir = extract_setting(output, "BUILD_DIR")
    if not build_dir:
        print("Could not derive BUILD_DIR from xcodebuild output", file=sys.stderr)
        sys.exit(1)

    root = derived_data_root(build_dir)
    package_swift = root / "SourcePackages" / "checkouts" / "Inspector" / "Package.swift"

    if package_swift.exists():
        print(package_swift.parent)
        return

    print(
        "Inspector package checkout not found under DerivedData. "
        "This app may be using a local package reference; provide the Inspector repo path manually.",
        file=sys.stderr,
    )
    sys.exit(2)


if __name__ == "__main__":
    main()
