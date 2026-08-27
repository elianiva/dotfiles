---
name: setup-pstack
description: Configure the Pi models pstack delegates to by role. Use for /setup-pstack, "configure pstack models", or changing pstack's model choices.
disable-model-invocation: true
---

# Set up pstack for Pi

Use `/setup-pstack` to open the Pi-native interactive model picker. It lists models configured for this Pi session and writes the chosen role mappings to `~/.pi/agent/pstack/models.json`.

If interactive UI is unavailable, call `pstack_config` with `action: "list-models"`, then set each needed role with `action: "set"`. Values use Pi's `provider/model` selector format. Set a role to `inherit-parent` to run that child with the parent session's selected model.

## Rules

- Never write an unlisted model selector.
- Start with `inherit-parent` for any role without a deliberate model choice.
- Panel roles can be configured as an array only by editing the JSON deliberately. Each entry means one subagent.
- Re-run `/setup-pstack` whenever models or provider access changes.

The config is user-level and applies to every later pstack session. It is not repository configuration and must not be committed.
