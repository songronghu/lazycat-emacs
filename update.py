import os
import pygit2

def reset_and_pull(repo_path):
    """Reset any changes and pull the latest updates."""
    repo = pygit2.Repository(repo_path)
    # Reset any changes
    repo.checkout_head(strategy=pygit2.GIT_CHECKOUT_FORCE)
    # Pull latest changes
    remote = repo.remotes['origin']
    remote.fetch()
    repo.merge(remote.head.target)

def update_main_repo():
    """Update the main repository."""
    print("Updating main repository...")
    reset_and_pull(os.getcwd())

def update_submodules():
    """Update each submodule to the commit specified in the main repo."""
    print("Updating submodules...")
    repo = pygit2.Repository(os.getcwd())
    for submodule in repo.submodules:
        submodule_path = os.path.join(repo.workdir, submodule.path)
        print(f"Processing submodule: {submodule.name} at {submodule_path}")

        # Reset any changes in the submodule
        reset_and_pull(submodule_path)

        # Check current branch and switch to master/main if necessary
        submodule_repo = pygit2.Repository(submodule_path)
        current_branch = submodule_repo.head.shorthand
        if current_branch not in ["master", "main"]:
            if "refs/heads/master" in submodule_repo.branches:
                submodule_repo.checkout("refs/heads/master")
            elif "refs/heads/main" in submodule_repo.branches:
                submodule_repo.checkout("refs/heads/main")

        # Update submodule to the commit specified in the main repo
        submodule.update(init=True, recursive=True)

if __name__ == "__main__":
    update_main_repo()
    update_submodules()
