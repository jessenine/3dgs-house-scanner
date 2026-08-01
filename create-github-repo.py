#!/usr/bin/env python3
"""
GitHub repo creation script for 3DGS House Scanner

Run this script and follow the prompts to create a GitHub repository.
"""

import subprocess
import sys
import os

def run_command(cmd, check=True):
    """Run a shell command and return output."""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=check)
        return result.stdout.strip(), result.stderr.strip(), result.returncode
    except Exception as e:
        return "", str(e), 1

def get_user_input(prompt, default=""):
    """Get user input with optional default."""
    try:
        value = input(f"{prompt} [{default}]: ").strip()
        return value if value else default
    except EOFError:
        return default

def main():
    print("=" * 60)
    print("GitHub Repository Creation for 3DGS House Scanner")
    print("=" * 60)
    print()
    
    # Get repository information
    repo_name = get_user_input("Repository name", "3dgs-house-scanner")
    repo_description = get_user_input("Repository description", "3D Gaussian Splatting tools for creating house scans from photos")
    visibility = get_user_input("Visibility (public/private)", "public")
    
    print()
    print(f"Creating repository: {repo_name}")
    print(f"Description: {repo_description}")
    print(f"Visibility: {visibility}")
    print()
    
    # Create GitHub repo using gh CLI
    print("Creating GitHub repository...")
    cmd = f"gh repo create {repo_name} --description \"{repo_description}\" --{visibility}"
    stdout, stderr, rc = run_command(cmd, check=False)
    
    if rc == 0:
        print(f"✓ Repository created: https://github.com/{os.environ.get('GITHUB_USER', 'YOUR_USERNAME')}/{repo_name}")
        print()
        print("Next steps:")
        print(f"  cd 3dgs-house-scanner")
        print("  git remote add origin https://github.com/YOUR_USERNAME/3dgs-house-scanner.git")
        print("  git push -u origin main")
        print()
        print("To set up your GitHub username for git:")
        print("  git config --global user.name 'Your Name'")
        print("  git config --global user.email 'your.email@example.com'")
        print("  gh auth login")
    else:
        print(f"✗ Failed to create repository")
        print(f"Error: {stderr}")
        print()
        print("Alternative: Create the repo manually at https://github.com/new")

if __name__ == "__main__":
    main()
