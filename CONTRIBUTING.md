# Contributing

Additions are welcome, including your own tool. This list exists because the other Polymarket lists filled up with dead links and vague descriptions, so the bar is about accuracy, not exclusivity.

## Adding an entry

1. Add one line to the section that fits, in this format:

   ```
   - [Name](https://example.com/) - What it does, concretely.
   ```

2. Keep the description to one or two sentences. Say what it tracks, what it outputs, and whether it is free or paid. Skip the adjectives: "revolutionary AI-powered real-time insights" tells a reader nothing and will be rewritten or rejected.

3. If you built it, say so in the pull request. That is not a problem, it just needs disclosing.

## Requirements

- **The link must resolve.** Run `./check-links.sh` before opening the pull request.
- **Chrome Web Store links need the full extension ID**, e.g. `https://chromewebstore.google.com/detail/some-name/abcdefghijklmnop`. A bare slug renders a generic store page and will be rejected.
- **Telegram links must point at the account you mean.** Handles get abandoned and re-registered, so check that `t.me/yourbot` still shows your bot's name.
- **No affiliate or tracking parameters** in the URL.
- **One entry per tool.** If a tool has a web app and a Telegram bot, pick the better entry point.

## Checking links

```bash
./check-links.sh          # check every link in README.md
```

The script fails only on links that are definitively dead (404, 410, 451). Hosts that block scripted requests (npm, Dune, Substack, Reddit) are reported separately as "could not verify", since CI runners get blocked where a browser works fine.

## Removing an entry

Open an issue or a pull request if a listed tool has shut down, changed URLs, or turned out to be something other than what its description claims. Removals are as useful as additions here.
