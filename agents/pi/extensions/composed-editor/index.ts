/**
 * Composed Editor - Combines starship-prompt + pi-ckers
 *
 * This is your local extension that composes multiple editor features.
 * Place this in ~/.pi/extensions/composed-editor/
 */

import { type ExtensionAPI, CustomEditor } from "@mariozechner/pi-coding-agent";
import type { Picker } from "@elianiva/pi-ckers";
import { createStarshipWidget, setupStarshipEvents } from "@elianiva/pi-starship";
import { withPickers } from "@elianiva/pi-ckers";
import { filePicker, dirPicker } from "@elianiva/pi-ckers/builtin/fff";
import { grepPicker } from "@elianiva/pi-ckers/builtin/grep";

// Compose: StarshipEditor + all builtin pickers
const pickers: Picker[] = [
  filePicker(),
  dirPicker(),
  grepPicker(),
];

const ComposedEditor = withPickers(CustomEditor, pickers);

export default function composedEditorExtension(pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    // if (!ctx.hasUI) return;
    //
    // // Set composed editor - pass ctx as 5th argument for picker initialization
    // ctx.ui.setEditorComponent(
    //   (tui, theme, keybindings) => new ComposedEditor(tui, theme, keybindings, undefined, ctx),
    // );

    // Clear footer
    // ctx.ui.setFooter(() => ({ invalidate() {}, render() { return []; } }));

    // // Set up starship widget
    // createStarshipWidget(pi, ctx);
  });

  // Set up starship event handlers
  // setupStarshipEvents(pi);
}
