import os
import subprocess

def run_command(command, cwd=None):
    """Run a shell command in a specific directory."""
    result = subprocess.run(command, shell=True, cwd=cwd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error running command: {command}\n{result.stderr}")
    return result.stdout.strip()

def update_main_repo():
    """Update the main repository."""
    print("Updating main repository...")
    # Reset any changes
    run_command("git checkout -- .")
    # Pull latest changes
    run_command("git pull")

def update_submodules():
    """Update each submodule to the commit specified in the main repo."""
    print("Updating submodules...")
    # Initialize and update submodules
    run_command("git submodule update --init --recursive")
    # Get the list of submodules
    submodules = run_command("git config --file .gitmodules --get-regexp path").splitlines()
    for submodule in submodules:
        path = submodule.split()[1]
        submodule_path = os.path.join(os.getcwd(), path)
        print(f"Processing submodule at {submodule_path}")

        # Reset any changes in the submodule
        run_command("git checkout -- .", cwd=submodule_path)

        # Check current branch and switch to master/main if necessary
        current_branch = run_command("git rev-parse --abbrev-ref HEAD", cwd=submodule_path)
        if current_branch not in ["master", "main"]:
            branches = run_command("git branch", cwd=submodule_path)
            if "master" in branches:
                run_command("git checkout master", cwd=submodule_path)
            elif "main" in branches:
                run_command("git checkout main", cwd=submodule_path)

        # Update submodule to the commit specified in the main repo
        run_command("git submodule update --recursive", cwd=submodule_path)

if __name__ == "__main__":
    update_main_repo()
    update_submodules()
