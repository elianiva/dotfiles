import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const messages = [
  "Schlepping...",
  "Combobulating...",
  "Doing...",
  "Channelling...",
  "Vibing...",
  "Concocting...",
  "Spelunking...",
  "Transmuting...",
  "Imagining...",
  "Pontificating...",
  "Whirring...",
  "Cogitating...",
  "Honking...",
  "Noodling...",
  "Percolating...",
  "Ruminating...",
  "Simmering...",
  "Marinating...",
  "Fermenting...",
  "Gestating...",
  "Hatching...",
  "Brewing...",
  "Steeping...",
  "Contemplating...",
  "Musing...",
  "Pondering...",
  "Dithering...",
  "Faffing...",
  "Puttering...",
  "Tinkering...",
  "Wrangling...",
  "Discombobulating...",
  "Recombobulating...",
  "Befuddling...",
  "Snorkeling...",
  "Yodeling...",
  "Zigzagging...",
  "Somersaulting...",
  "Canoodling...",
  "Schmoozing...",
  "Skedaddling...",
  "Scampering...",
  "Swashbuckling...",
  "Effervescing...",
  "Bubbling...",
  "Enchanting...",
  "Mesmerizing...",
  "Sparkling...",
  "Scintillating...",
  "Synthesizing...",
  "Procrastinating...",
  "Dillydallying...",
  "Lollygagging...",
  "Sleuthing...",
  "Rummaging...",
  "Foraging...",
  "Vamoosing...",
  "Absconding...",
  "Jamming...",
  "Freestyling...",
  "Frolicking...",
  "Wibbling...",
  "Wobbling...",
  "Bonking...",
  "Squelching...",
  "Burbling...",
  "Whooshing...",
  "Clunking...",
  "Rustling...",
  "Bustling...",
  "Doodling...",
  "Squiggling...",
  "Slithering...",
  "Bouldering...",
  "Tottering...",
  "Jittering...",
  "Twittering...",
  "Chattering...",
  "Splattering...",
  "Hammering...",
  "Stammering...",
  "Shimmering...",
  "Glimmering...",
  "Skimming...",
  "Drumming...",
  "Fumbling...",
  "Grumbling...",
  "Mumbling...",
  "Rumbling...",
  "Stumbling...",
  "Crumbling...",
  "Tangling...",
  "Jangling...",
  "Mingling...",
  "Jingling...",
  "Bribing the compiler...",
  "Tickling the stack...",
  "Massaging the heap...",
  "Summoning semicolons...",
  "Herding pointers...",
  "Untangling spaghetti...",
  "Polishing the algorithms...",
  "Waxing philosophical...",
  "Reading tea leaves...",
  "Warming up the hamsters...",
  "Caffeinating...",
  "Squinting at the problem...",
  "Staring into the abyss...",
  "Communing with the machine spirit...",
  "Reticulating splines...",
  "Calibrating the flux capacitor...",
];

let agentStartMs: number | null = null;
let timerInterval: ReturnType<typeof setInterval> | null = null;
let currentMessage: string | null = null;
let totalTokens = 0;

function pickRandom(): string {
  return messages[Math.floor(Math.random() * messages.length)];
}

function formatTokenCount(n: number): string {
  if (n < 1000) return String(n) + " tokens";
  return (n / 1000).toFixed(1) + "k tokens";
}

function formatDuration(ms: number): string {
  const seconds = Math.floor(ms / 1000);
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  if (mins > 0) return String(mins) + "m " + String(secs) + "s";
  return String(secs) + "s";
}

function isAssistantMessage(message: unknown): message is AssistantMessage {
  if (!message || typeof message !== "object") return false;
  return (message as { role?: unknown }).role === "assistant";
}

export default function (pi: ExtensionAPI) {
  pi.on("agent_start", async (_event, ctx) => {
    agentStartMs = Date.now();
    currentMessage = pickRandom();
    totalTokens = 0;

    ctx.ui.setWorkingMessage(currentMessage);

    timerInterval = setInterval(() => {
      if (agentStartMs === null || currentMessage === null) return;
      const elapsedMs = Date.now() - agentStartMs;
      const usage = ctx.getContextUsage();
      const tokens = usage ? usage.tokens : totalTokens;
      const msg = currentMessage + " " + formatDuration(elapsedMs) + " ⋅ " + formatTokenCount(tokens);
      ctx.ui.setWorkingMessage(msg);
    }, 1000);
  });

  pi.on("message_end", async (event, ctx) => {
    if (event.message.role !== "assistant") return;
    const usage = event.message.usage;
    if (usage) {
      totalTokens = usage.input + usage.output;
    }
  });

  pi.on("agent_end", (event, ctx) => {
    if (!ctx.hasUI) return;
    if (agentStartMs === null) return;

    if (timerInterval !== null) {
      clearInterval(timerInterval);
      timerInterval = null;
    }

    const elapsedMs = Date.now() - agentStartMs;
    agentStartMs = null;
    if (elapsedMs <= 0) return;

    let output = 0;
    for (const msg of event.messages) {
      if (!isAssistantMessage(msg)) continue;
      output += msg.usage.output || 0;
    }

    if (output <= 0) return;

    const finalTps = output / (elapsedMs / 1000);
    const msg = formatDuration(elapsedMs) + " ⋅ " + formatTokenCount(output) + " ⋅ " + finalTps.toFixed(1) + " tok/s";
    ctx.ui.setWorkingMessage(msg);
    ctx.ui.notify(msg, "info");
  });
}
