# Developer Guide

How to set up this repo on your machine, what each `make` command does, and why the
tooling is the way it is. Read "Quick start" first; everything else is reference.

## Quick start

You only need **uv** and **make**. The setup script installs uv if it's missing.

```sh
# 1. Your own SSH key for this project (once per computer, never share the private file)
ssh-keygen -t ed25519 -f ~/.ssh/cloud1 -C "<your-login>@cloud-1"

# 2. Install everything + create the local VMs
make setup-dev

# 3. Check that Ansible reaches the VMs
uv run ansible -i inventory/local.ini cloud1 -m ping
```

Expected result of step 3: `node1 | SUCCESS ... "pong"` and the same for `node2`.

| Your computer | Step 2 |
|---------------|--------|
| Mac | `make setup-dev` installs multipass with brew and creates the VMs |
| Your own Linux | `make setup-dev` sets up the tools, prints `sudo snap install multipass`, then stops with a red "Multipass not detected". Run the snap command, then `make setup-dev` again |
| Classroom computers | `make setup` only: no sudo there, so no multipass and no local VMs |

> Your public key (`~/.ssh/cloud1.pub`) must be listed in `cloud-init.yml`, or the VMs
> won't let you in. Both of ours are already there. A new computer needs a new key added
> there, then `make vms-destroy && make vms-up` (cloud-init only runs on first boot).

## Why uv instead of `brew install pre-commit`

Installing tools by hand (brew, pip) gives each of us **different versions** on each
computer, and the classroom computers have no brew at all. Different versions mean
different lint results and "works on my machine" bugs.

**uv** fixes that: it reads the project files and builds an identical environment
(`.venv/`) everywhere, with the exact same Python and tool versions.

| File | What it pins |
|------|--------------|
| `pyproject.toml` | Python `3.13.*`, `ansible-core==2.21.5`, `pre-commit==4.7.0` |
| `uv.lock` | the exact versions of everything, including sub-dependencies |
| `.python-version` | which Python uv uses (downloads it if missing) |

You never install Ansible or pre-commit yourself. `make setup` runs `uv sync`, and
`uv run <command>` runs a tool from the project's environment. Or activate it once per
terminal with `source .venv/bin/activate` and type commands directly.

## What pre-commit does

pre-commit runs checks **on every `git commit`** and blocks the commit if one fails.
`make setup` installs it as a git hook (`.git/hooks/pre-commit`).

| Check | Catches |
|-------|---------|
| trailing-whitespace, end-of-file-fixer | messy whitespace (these **fix** the file, then you `git add` again) |
| check-yaml, yamllint | broken or badly formatted YAML |
| **gitleaks** | passwords, tokens and private keys before they reach GitHub |
| ansible-lint | Ansible mistakes and bad practices |

- A hook that **fixes** a file aborts the commit: run `git add` and commit again.
- `make lint` runs every check on every file without committing.
- Checks run on **commit**, not on push.

## Make commands

Run `make` (or `make help`) to see the menu. **Blue** = everyone, **magenta** = only for
local development with VMs (your own Mac or Linux, not the classroom).

### Setup

| Command | Does | When |
|---------|------|------|
| `make setup` | installs uv if missing, builds `.venv`, installs the git hook | once per computer, or after `fclean` |
| `make setup-dev` | `setup` + multipass (Mac: installs it, Linux: prints the snap command) + `vms-up` | once on your own computer |

### Local VMs (multipass, not on classroom computers)

Two Ubuntu 22.04 VMs (`node1`, `node2`) to test the playbook without paying for cloud servers.

| Command | Does |
|---------|------|
| `make vms-up` | creates the VMs if missing, starts them if stopped, and writes `inventory/local.ini` with their current IPs |
| `make vms-down` | stops them (disks are kept, quick to start again) |
| `make vms-destroy` | deletes them for good |

`make vms-up` is safe to run any time. VM IPs change every time VMs are recreated,
which is why the inventory file is generated and not committed.

### Quality and cleanup

| Command | Removes |
|---------|---------|
| `make lint` | nothing: runs all pre-commit checks on all files |
| `make clean` | `.ansible/` (Ansible's local cache) |
| `make devclean` | `clean` + the VMs |
| `make fclean` | `devclean` + `.venv` + the git hook: back to a fresh clone |

> After `fclean` there is **no git hook**: run `make setup` before your next commit,
> or nothing gets checked (gitleaks included).

## How the Ansible side fits together

| File | Role |
|------|------|
| `cloud-init.yml` | runs on a VM's first boot: adds our public SSH keys |
| `inventory/local.ini` | the local VMs and their IPs (generated, gitignored) |
| `inventory/aws.ini` | the AWS servers (later, committed) |
| `ansible.cfg` | shared settings: user `ubuntu`, key `~/.ssh/cloud1`, Python on the servers |
| `site.yml` | the main playbook: what gets installed and configured |
| `roles/` | the playbook split by topic (`common`, `docker`, `firewall`, `app`, ...) |

`ansible.cfg` has **no default inventory** on purpose: you always choose with `-i`, so a
test can never hit the real servers by accident.

```sh
uv run ansible-playbook -i inventory/local.ini site.yml    # local VMs
```

Later: `make deploy-local` (VMs) and `make deploy` (AWS) will wrap this.

## Who does what

| Person A (rmanzana) | Person B (pshcherb) |
|---------------------|---------------------|
| tooling, VMs, inventory, `ansible.cfg` | `docker-compose.yml`, nginx config |
| roles `common`, `docker`, `firewall` | role `app` (deploys the compose stack) |

The `app` role needs Docker on the servers, so it runs **after** the `docker` role in
`site.yml`. Until that role exists, test the compose stack locally with Docker Desktop.

## Gotchas we already hit

| Symptom | Cause | Fix |
|---------|-------|-----|
| Lint says "missing space" but you see one | a **non-breaking space** (Option+Space on Mac) | delete it and type a normal space |
| Commit aborted, "files were modified by this hook" | a fixer hook changed the file | `git add` the file and commit again |
| `REMOTE HOST IDENTIFICATION HAS CHANGED` | a new VM got an old VM's IP | `ssh-keygen -R <ip>` (`make vms-up` does it for new VMs) |
| A setting in `ansible.cfg` has a weird value | `#` after a value becomes part of the value | put comments on their own line |
| Pasted shell commands with `# comments` fail in zsh | zsh ignores `#` comments when typed | remove the comment, or `setopt interactive_comments` |
| `UNREACHABLE` on ping | VMs are stopped | `make vms-up` |
