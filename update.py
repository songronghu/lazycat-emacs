import os
import subprocess
from git import Repo

def run_command(command, cwd=None):
    """Run a shell command in a specific directory."""
    result = subprocess.run(command, shell=True, cwd=cwd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error running command: {command}\n{result.stderr}")
    return result.stdout.strip()

def update_main_repo():
    """Update the main repository and reset uncommitted changes."""
    print("Updating main repository...")
    run_command("git checkout -- .")
    run_command("git pull")

def update_submodules():
    """Update each submodule to the commit specified in the main repo."""
    print("Updating submodules...")
    repo = Repo(os.getcwd())
    for submodule in repo.submodules:
        submodule_path = submodule.abspath
        print(f"Processing submodule: {submodule.name} at {submodule_path}")

        # Reset any changes in the submodule
        run_command("git checkout -- .", cwd=submodule_path)

        # Check current branch and switch to master/main
        current_branch = run_command("git rev-parse --abbrev-ref HEAD", cwd=submodule_path)
        if current_branch not in ["master", "main"]:
            if "master" in run_command("git branch", cwd=submodule_path):
                run_command("git checkout master", cwd=submodule_path)
            elif "main" in run_command("git branch", cwd=submodule_path):
                run_command("git checkout main", cwd=submodule_path)

        # Update submodule to the commit specified in the main repo
        submodule.update(init=True, recursive=True)

if __name__ == "__main__":
    update_main_repo()
    update_submodules()
