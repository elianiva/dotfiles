import { access as fsAccess, readFile as fsReadFile } from "fs/promises";
import { constants } from "fs";
import { extname } from "path";
import type { ImageContent, TextContent } from "@mariozechner/pi-ai";
import { Type } from "@sinclair/typebox";

// Much higher defaults than the built-in read tool (2000 lines / 50KB)
export const CUSTOM_MAX_LINES = 100_000;
export const CUSTOM_MAX_BYTES = 10 * 1024 * 1024; // 10MB

const IMAGE_MIME_TYPES: Record<string, string> = {
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".png": "image/png",
  ".gif": "image/gif",
  ".webp": "image/webp",
};

function isImageFile(filePath: string): string | null {
  const ext = extname(filePath).toLowerCase();
  return IMAGE_MIME_TYPES[ext] || null;
}

function formatSize(bytes: number): string {
  if (bytes < 1024) return `${bytes}B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)}KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)}MB`;
}

const readSchema = Type.Object({
  path: Type.String({ description: "Path to the file to read (relative or absolute)" }),
  offset: Type.Optional(
    Type.Number({ description: "Line number to start reading from (1-indexed)" }),
  ),
  limit: Type.Optional(Type.Number({ description: "Maximum number of lines to read" })),
});

export interface ReadToolOptions {
  maxLines?: number;
  maxBytes?: number;
}

export function createCustomReadTool(cwd: string, options?: ReadToolOptions) {
  const maxLines = options?.maxLines ?? CUSTOM_MAX_LINES;
  const maxBytes = options?.maxBytes ?? CUSTOM_MAX_BYTES;

  return {
    name: "read",
    label: "read",
    description: `Read the contents of a file. Supports text files and images (jpg, png, gif, webp). Images are sent as attachments. For text files, output is truncated to ${maxLines.toLocaleString()} lines or ${formatSize(maxBytes)} (whichever is hit first). Use offset/limit for large files. When you need the full file, continue with offset until complete.`,
    parameters: readSchema,
    execute: async (
      _toolCallId: string,
      { path, offset, limit }: { path: string; offset?: number; limit?: number },
      signal?: AbortSignal,
    ): Promise<{ content: (TextContent | ImageContent)[] }> => {
      if (signal?.aborted) throw new Error("Operation aborted");

      const absolutePath = path.startsWith("/") ? path : `${cwd}/${path}`;

      // Check accessibility
      try {
        await fsAccess(absolutePath, constants.R_OK);
      } catch {
        throw new Error(`File not readable: ${path}`);
      }

      const mimeType = isImageFile(absolutePath);
      if (mimeType) {
        // Read image as base64
        const buffer = await fsReadFile(absolutePath);
        const base64 = buffer.toString("base64");
        return {
          content: [
            { type: "text", text: `Read image file [${mimeType}]` },
            { type: "image", data: base64, mimeType },
          ],
        };
      }

      // Read text file
      const buffer = await fsReadFile(absolutePath);
      const textContent = buffer.toString("utf-8");
      const allLines = textContent.split("\n");
      const totalFileLines = allLines.length;

      // Apply offset (1-indexed)
      const startLine = offset ? Math.max(0, offset - 1) : 0;
      const startLineDisplay = startLine + 1;

      if (startLine >= allLines.length) {
        throw new Error(`Offset ${offset} is beyond end of file (${allLines.length} lines total)`);
      }

      // Slice content based on offset/limit
      let selectedLines: string[];
      let userLimitApplied = false;

      if (limit !== undefined) {
        const endLine = Math.min(startLine + limit, allLines.length);
        selectedLines = allLines.slice(startLine, endLine);
        userLimitApplied = endLine - startLine < allLines.length - startLine;
      } else {
        selectedLines = allLines.slice(startLine);
      }

      // Apply our own truncation (much higher limits)
      const result = truncateHead(selectedLines.join("\n"), { maxLines, maxBytes });

      let outputText: string;

      if (result.firstLineExceedsLimit) {
        const firstLineSize = formatSize(Buffer.byteLength(selectedLines[0] || "", "utf-8"));
        outputText = `[Line ${startLineDisplay} is ${firstLineSize}, exceeds ${formatSize(maxBytes)} limit. Use bash: sed -n '${startLineDisplay}p' ${path} | head -c ${maxBytes}]`;
      } else if (result.truncated) {
        const endLineDisplay = startLineDisplay + result.outputLines - 1;
        const nextOffset = endLineDisplay + 1;
        outputText = result.content;
        if (result.truncatedBy === "lines") {
          outputText += `\n\n[Showing lines ${startLineDisplay}-${endLineDisplay} of ${totalFileLines}. Use offset=${nextOffset} to continue.]`;
        } else {
          outputText += `\n\n[Showing lines ${startLineDisplay}-${endLineDisplay} of ${totalFileLines} (${formatSize(maxBytes)} limit). Use offset=${nextOffset} to continue.]`;
        }
      } else if (userLimitApplied) {
        const endLine = startLine + (limit ?? 0);
        const remaining = totalFileLines - endLine;
        const nextOffset = endLine + 1;
        outputText = result.content;
        outputText += `\n\n[${remaining} more lines in file. Use offset=${nextOffset} to continue.]`;
      } else {
        outputText = result.content;
      }

      return {
        content: [{ type: "text", text: outputText }],
      };
    },
  };
}

interface TruncationResult {
  content: string;
  truncated: boolean;
  truncatedBy: "lines" | "bytes" | null;
  outputLines: number;
  firstLineExceedsLimit: boolean;
}

interface TruncationOptions {
  maxLines: number;
  maxBytes: number;
}

function truncateHead(content: string, options: TruncationOptions): TruncationResult {
  const { maxLines, maxBytes } = options;
  const totalBytes = Buffer.byteLength(content, "utf-8");
  const lines = content.split("\n");
  const totalLines = lines.length;

  if (totalLines <= maxLines && totalBytes <= maxBytes) {
    return {
      content,
      truncated: false,
      truncatedBy: null,
      outputLines: totalLines,
      firstLineExceedsLimit: false,
    };
  }

  // Check if first line alone exceeds limit
  const firstLineBytes = Buffer.byteLength(lines[0], "utf-8");
  if (firstLineBytes > maxBytes) {
    return {
      content: "",
      truncated: true,
      truncatedBy: "bytes",
      outputLines: 0,
      firstLineExceedsLimit: true,
    };
  }

  const outputLinesArr: string[] = [];
  let outputBytesCount = 0;
  let truncatedBy: "lines" | "bytes" = "lines";

  for (let i = 0; i < lines.length && i < maxLines; i++) {
    const line = lines[i];
    const lineBytes = Buffer.byteLength(line, "utf-8") + (i > 0 ? 1 : 0);
    if (outputBytesCount + lineBytes > maxBytes) {
      truncatedBy = "bytes";
      break;
    }
    outputLinesArr.push(line);
    outputBytesCount += lineBytes;
  }

  if (outputLinesArr.length >= maxLines && outputBytesCount <= maxBytes) {
    truncatedBy = "lines";
  }

  return {
    content: outputLinesArr.join("\n"),
    truncated: true,
    truncatedBy,
    outputLines: outputLinesArr.length,
    firstLineExceedsLimit: false,
  };
}
