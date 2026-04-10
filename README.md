# new-dev-container

Minimal SSH-capable development image built on top of `unsloth/unsloth`.

It exists to make Vast.ai SSH startup reliable while keeping the image close to the
upstream Unsloth environment.

The image:

- installs `openssh-server` and `tmux`
- fixes `/run/sshd` permissions at startup
- starts `sshd` in the foreground
- optionally drops new SSH sessions into a `tmux` session named `main`

Set `DISABLE_AUTO_TMUX=1` to disable the automatic tmux wrapper.
