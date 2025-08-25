#!/usr/bin/env python3
"""check_architecture.py

Lightweight checker that enforces a subset of `Tools/ARCHITECTURE.md` rules.
This script emits warnings and exit 0 for warn-only mode, or non-zero for strict mode.
"""
import argparse
import os
import sys

def check_project(path, warn_only=True):
    issues = []
    # Rule: No Swift files under SharedTypes should import SwiftUI
    for root, _dirs, files in os.walk(path):
        for f in files:
            if f.endswith('.swift'):
                fp = os.path.join(root, f)
                try:
                    with open(fp, 'r', encoding='utf-8') as fh:
                        txt = fh.read()
                        if 'SharedTypes' in root and 'import SwiftUI' in txt:
                            issues.append(f"{fp}: SharedTypes must not import SwiftUI")
                except Exception:
                    pass

    # Example rule: Avoid TODO/FIXME in code
    todo_count = 0
    for root, _dirs, files in os.walk(path):
        for f in files:
            if f.endswith(('.swift', '.py', '.sh')):
                fp = os.path.join(root, f)
                try:
                    with open(fp, 'r', encoding='utf-8') as fh:
                        for line in fh:
                            if 'TODO' in line or 'FIXME' in line:
                                todo_count += 1
                except Exception:
                    pass
    if todo_count > 50:
        issues.append(f"Project has {todo_count} TODO/FIXME markers; consider cleaning up")

    return issues

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--project', required=True)
    parser.add_argument('--warn-only', action='store_true', default=False)
    args = parser.parse_args()

    path = args.project
    if not os.path.isdir(path):
        print(f"Project path not found: {path}")
        sys.exit(2)

    issues = check_project(path, warn_only=args.warn_only)
    if issues:
        print("Architecture issues detected:")
        for it in issues:
            print(f" - {it}")
        if args.warn_only:
            print("Warn-only mode: continuing with warnings")
            sys.exit(0)
        else:
            print("Strict mode: failing")
            sys.exit(1)
    else:
        print("No architecture issues detected")
        sys.exit(0)

if __name__ == '__main__':
    main()
