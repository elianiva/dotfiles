import { Theme } from "@mariozechner/pi-coding-agent";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

/**
 * Extension that overrides markdown bold and italic formatting to use colors instead.
 *
 * It monkey-patches the Theme prototype so it works across all themes
 * and doesn't require polling.
 */
export default function (pi: ExtensionAPI) {
  const originalBold = Theme.prototype.bold;
  const originalItalic = Theme.prototype.italic;

  // Override bold to use 'warning' color (usually yellow/orange)
  Theme.prototype.bold = function(this: Theme, text: string) {
    return originalBold(this.fg("error", text));
  };

  // Override italic to use 'accent' color (usually teal/cyan)
  Theme.prototype.italic = function(this: Theme, text: string) {
    return originalItalic(this.fg("accent", text));
  };

  // Restore originals on shutdown
  pi.on("session_shutdown", () => {
    Theme.prototype.bold = originalBold;
    Theme.prototype.italic = originalItalic;
  });
}
