import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/**
 * Block-level streaming display.
 *
 * While the assistant is streaming, this buffers rendered output so
 * completed paragraphs/blocks appear one at a time instead of
 * token-by-token. When the message finalizes, the full text renders.
 *
 * How it works: on every streaming update pi passes the FULL accumulated
 * markdown through registered transformers. We return only the portion up
 * to the last safe block boundary (blank line outside code fences);
 * everything after it is withheld until its block completes. Code fences
 * are treated atomically — they only appear once fully closed.
 *
 * Display-only: session storage, LLM context, RPC events, and print mode
 * are untouched.
 */

// Apply the same buffering to thinking blocks ("assistant-thinking").
const BUFFER_THINKING = true;

/**
 * Index just past the last blank line that sits outside any code fence,
 * or -1 if none. A blank line outside a fence = paragraph boundary;
 * content after it belongs to a still-incomplete block.
 */
export function lastBlockBoundary(markdown: string): number {
  const lines = markdown.split("\n");
  let inFence = false;
  let offset = 0;
  let boundary = -1;

  for (const line of lines) {
    if (!inFence && line.trim() === "") {
      boundary = offset + line.length + 1; // keep the newline itself
    }
    if (/^\s*(`{3,}|~{3,})/.test(line)) {
      inFence = !inFence;
    }
    offset += line.length + 1;
  }

  return boundary;
}

export default function (pi: ExtensionAPI) {
  // Whether the CURRENTLY streaming assistant message already contains a
  // toolCall block. Message content is ordered — thinking/text always come
  // before tool calls — so once a toolCall appears, everything before it is
  // finished and must be revealed in full, even though the message as a
  // whole keeps streaming while the remaining tool-call args arrive.
  // Without this, thinking with no \n\n breaks stays hidden until ALL
  // parallel tool calls finish streaming.
  let toolCallsStarted = false;

  pi.on("message_start", (event) => {
    if (event.message.role === "assistant") toolCallsStarted = false;
  });

  pi.on("message_update", (event) => {
    if (event.message.role !== "assistant") return;
    if (!toolCallsStarted) {
      toolCallsStarted = event.message.content.some((c) => c.type === "toolCall");
    }
  });

  pi.on("message_end", () => {
    toolCallsStarted = false;
  });

  pi.registerMarkdownTransformer((markdown, { messageType, isStreaming }) => {
    const applies =
      isStreaming &&
      !toolCallsStarted &&
      (messageType === "assistant" ||
        (BUFFER_THINKING && messageType === "assistant-thinking"));

    // Finalized messages, restored sessions, width re-renders, user messages,
    // and anything after the first tool call passes through untouched.
    if (!applies) return markdown;

    const boundary = lastBlockBoundary(markdown);
    if (boundary <= 0) return ""; // first block still streaming

    return markdown.slice(0, boundary);
  });
}
