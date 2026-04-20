# Claude Keepalive

Fires a headless `claude --print "."` on a schedule so a Claude Pro 5-hour
usage window is always warm during your workday.

## Schedule (Asia/Kolkata, Mon–Fri)
### You can customize this based on your work timings
### Note: This will work if your laptop is on/suspended not shut down.

| Fire time | Window covers       | Why                                         |
|-----------|--------------------|---------------------------------------------|
| 07:30     | 07:30 → 12:30      | Active before you sit down at 10:00         |
| 12:25     | 12:25 → 17:25      | Refresh 5 min before window 1 expires       |
| 17:20     | 17:20 → 22:20      | Refresh 5 min before window 2 expires       |

Covers 07:30 → 22:20, no gaps. You work 10:00–19:00 comfortably inside.

## Install

```bash
cd claude-keepalive
chmod +x claude-keepalive.sh install.sh uninstall.sh
./install.sh
```

Optional but recommended — lets the timer fire even when you're logged out:

```bash
sudo loginctl enable-linger $USER
```

## Verify

```bash
# See when it'll next fire
systemctl --user list-timers claude-keepalive.timer

# Fire one manually to confirm it works
systemctl --user start claude-keepalive.service

# Watch the log
tail -f ~/.claude-keepalive.log
```

Expected log line on success:

```
[2026-04-17 12:25:08 IST] START ping via /home/abhi/.local/bin/claude
[2026-04-17 12:25:11 IST] OK  reply='Hello! How can I help you today?'
```

## Change the schedule

Edit `~/.config/systemd/user/claude-keepalive.timer`, then:

```bash
systemctl --user daemon-reload
systemctl --user restart claude-keepalive.timer
```

## Uninstall

```bash
./uninstall.sh
```

## Notes

- The script pins `--model sonnet` to keep pings cheap. Change in
  `claude-keepalive.sh` if you want Opus warmth instead.
- Each ping consumes one message from your Pro quota. Three/day × 5 weekdays =
  ~15 pings/week. Negligible.
- If `claude` lives somewhere odd (e.g., managed by `fnm` or a non-default
  nvm version), edit the `Environment=PATH=` line in
  `claude-keepalive.service` to include that path.
