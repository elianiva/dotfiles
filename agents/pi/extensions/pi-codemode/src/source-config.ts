import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import { parse, printParseErrorCode, type ParseError } from "jsonc-parser";

const SECRET_REF_PREFIX = "secret-public-ref:";

type UnknownRecord = Record<string, unknown>;

type HeaderSecretRef = { secretId: string; prefix?: string };
type PluginHeaderValue = string | HeaderSecretRef;

export type OpenApiSourceConfig = {
  kind: "openapi";
  spec: string;
  baseUrl?: string;
  namespace?: string;
  headers?: Record<string, PluginHeaderValue>;
};

export type GraphqlSourceConfig = {
  kind: "graphql";
  endpoint: string;
  introspectionJson?: string;
  namespace?: string;
  headers?: Record<string, PluginHeaderValue>;
};

export type McpRemoteSourceConfig = {
  kind: "mcp";
  transport: "remote";
  name: string;
  endpoint: string;
  remoteTransport?: "streamable-http" | "sse" | "auto";
  namespace?: string;
  queryParams?: Record<string, string>;
  headers?: Record<string, string>;
};

export type McpStdioSourceConfig = {
  kind: "mcp";
  transport: "stdio";
  name: string;
  command: string;
  args?: string[];
  env?: Record<string, string>;
  cwd?: string;
  namespace?: string;
};

export type SupportedSourceConfig =
  | OpenApiSourceConfig
  | GraphqlSourceConfig
  | McpRemoteSourceConfig
  | McpStdioSourceConfig;

export type UnsupportedSourceConfig = {
  index: number;
  reason: string;
  value: unknown;
  kind?: string;
};

export type LoadedSourceConfig = {
  configPath: string;
  fingerprint: string;
  sources: SupportedSourceConfig[];
  unsupported: UnsupportedSourceConfig[];
};

const isRecord = (value: unknown): value is UnknownRecord =>
  typeof value === "object" && value !== null && !Array.isArray(value);

const parseStringMap = (value: unknown): Record<string, string> | null => {
  if (!isRecord(value)) return null;
  const output: Record<string, string> = {};
  for (const [key, item] of Object.entries(value)) {
    if (typeof item !== "string") return null;
    output[key] = item;
  }
  return output;
};

const parseStringArray = (value: unknown): string[] | null => {
  if (!Array.isArray(value)) return null;
  if (value.some((item) => typeof item !== "string")) return null;
  return [...value] as string[];
};

const parseHeaderValue = (value: unknown): PluginHeaderValue | null => {
  if (typeof value === "string") {
    if (value?.startsWith(SECRET_REF_PREFIX)) {
      return { secretId: value.slice(SECRET_REF_PREFIX.length) };
    }
    return value;
  }

  if (!isRecord(value) || typeof value.value !== "string") return null;

  const prefix = typeof value.prefix === "string" ? value.prefix : undefined;
  const raw = value.value;

  if (raw?.startsWith(SECRET_REF_PREFIX)) {
    const secretId = raw.slice(SECRET_REF_PREFIX.length);
    return prefix ? { secretId, prefix } : { secretId };
  }

  return prefix ? prefix + raw : raw;
};

const parseHeaderMap = (value: unknown): Record<string, PluginHeaderValue> | null => {
  if (!isRecord(value)) return null;
  const output: Record<string, PluginHeaderValue> = {};
  for (const [key, item] of Object.entries(value)) {
    const parsed = parseHeaderValue(item);
    if (parsed == null) return null;
    output[key] = parsed;
  }
  return output;
};

const parseMcpSource = (entry: UnknownRecord): { source?: SupportedSourceConfig; reason?: string } => {
  const transport = entry.transport;
  if (transport !== "remote" && transport !== "stdio") {
    return { reason: "mcp.transport must be \"remote\" or \"stdio\"" };
  }

  if (typeof entry.name !== "string" || entry.name.trim().length === 0) {
    return { reason: "mcp.name must be a non-empty string" };
  }

  if (entry.namespace !== undefined && typeof entry.namespace !== "string") {
    return { reason: "mcp.namespace must be a string" };
  }

  if (transport === "remote") {
    if (typeof entry.endpoint !== "string" || entry.endpoint.trim().length === 0) {
      return { reason: "mcp(remote).endpoint must be a non-empty string" };
    }

    if (
      entry.remoteTransport !== undefined &&
      entry.remoteTransport !== "streamable-http" &&
      entry.remoteTransport !== "sse" &&
      entry.remoteTransport !== "auto"
    ) {
      return { reason: "mcp(remote).remoteTransport must be streamable-http|sse|auto" };
    }

    if (entry.queryParams !== undefined && parseStringMap(entry.queryParams) == null) {
      return { reason: "mcp(remote).queryParams must be a string map" };
    }

    if (entry.headers !== undefined && parseStringMap(entry.headers) == null) {
      return { reason: "mcp(remote).headers must be a string map" };
    }

    return {
      source: {
        kind: "mcp",
        transport: "remote",
        name: entry.name,
        endpoint: entry.endpoint,
        remoteTransport: entry.remoteTransport,
        namespace: entry.namespace,
        queryParams: entry.queryParams as Record<string, string> | undefined,
        headers: entry.headers as Record<string, string> | undefined,
      },
    };
  }

  if (typeof entry.command !== "string" || entry.command.trim().length === 0) {
    return { reason: "mcp(stdio).command must be a non-empty string" };
  }

  if (entry.args !== undefined && parseStringArray(entry.args) == null) {
    return { reason: "mcp(stdio).args must be a string array" };
  }

  if (entry.env !== undefined && parseStringMap(entry.env) == null) {
    return { reason: "mcp(stdio).env must be a string map" };
  }

  if (entry.cwd !== undefined && typeof entry.cwd !== "string") {
    return { reason: "mcp(stdio).cwd must be a string" };
  }

  return {
    source: {
      kind: "mcp",
      transport: "stdio",
      name: entry.name,
      command: entry.command,
      args: entry.args as string[] | undefined,
      env: entry.env as Record<string, string> | undefined,
      cwd: entry.cwd as string | undefined,
      namespace: entry.namespace,
    },
  };
};

const parseOpenApiSource = (entry: UnknownRecord): { source?: SupportedSourceConfig; reason?: string } => {
  if (typeof entry.spec !== "string" || entry.spec.trim().length === 0) {
    return { reason: "openapi.spec must be a non-empty string" };
  }

  if (entry.baseUrl !== undefined && typeof entry.baseUrl !== "string") {
    return { reason: "openapi.baseUrl must be a string" };
  }

  if (entry.namespace !== undefined && typeof entry.namespace !== "string") {
    return { reason: "openapi.namespace must be a string" };
  }

  const headers = entry.headers === undefined ? undefined : parseHeaderMap(entry.headers);
  if (entry.headers !== undefined && headers == null) {
    return { reason: "openapi.headers must map to string or secret refs" };
  }

  return {
    source: {
      kind: "openapi",
      spec: entry.spec,
      baseUrl: entry.baseUrl as string | undefined,
      namespace: entry.namespace as string | undefined,
      headers: headers ?? undefined,
    },
  };
};

const parseGraphqlSource = (entry: UnknownRecord): { source?: SupportedSourceConfig; reason?: string } => {
  if (typeof entry.endpoint !== "string" || entry.endpoint.trim().length === 0) {
    return { reason: "graphql.endpoint must be a non-empty string" };
  }

  if (entry.introspectionJson !== undefined && typeof entry.introspectionJson !== "string") {
    return { reason: "graphql.introspectionJson must be a string" };
  }

  if (entry.namespace !== undefined && typeof entry.namespace !== "string") {
    return { reason: "graphql.namespace must be a string" };
  }

  const headers = entry.headers === undefined ? undefined : parseHeaderMap(entry.headers);
  if (entry.headers !== undefined && headers == null) {
    return { reason: "graphql.headers must map to string or secret refs" };
  }

  return {
    source: {
      kind: "graphql",
      endpoint: entry.endpoint,
      introspectionJson: entry.introspectionJson as string | undefined,
      namespace: entry.namespace as string | undefined,
      headers: headers ?? undefined,
    },
  };
};

const parseErrorsToMessage = (errors: ParseError[]): string =>
  errors.map((error) => "offset " + error.offset + ": " + printParseErrorCode(error.error)).join("; ");

const hashContent = (content: string): string =>
  "sha256:" + createHash("sha256").update(content).digest("hex");

export const getExecutorConfigPath = (): string => join(homedir(), ".pi", "agent", "executor.jsonc");

export const loadSourcesFromConfig = async (): Promise<LoadedSourceConfig> => {
  const configPath = getExecutorConfigPath();

  let raw: string;
  try {
    raw = await readFile(configPath, "utf8");
  } catch (cause) {
    const error = cause as NodeJS.ErrnoException;
    if (error?.code === "ENOENT") {
      return {
        configPath,
        fingerprint: "missing",
        sources: [],
        unsupported: [],
      };
    }
    throw new Error("Failed reading " + configPath + ": " + (error?.message ?? String(cause)));
  }

  const parseErrors: ParseError[] = [];
  const parsed = parse(raw, parseErrors);
  if (parseErrors.length > 0) {
    throw new Error("Invalid JSONC in " + configPath + ": " + parseErrorsToMessage(parseErrors));
  }

  if (!isRecord(parsed)) {
    throw new Error("Invalid config at " + configPath + ": root must be an object");
  }

  const fingerprint = hashContent(raw);
  const rawSources = parsed.sources;

  if (rawSources === undefined) {
    return { configPath, fingerprint, sources: [], unsupported: [] };
  }

  if (!Array.isArray(rawSources)) {
    throw new Error("Invalid config at " + configPath + ": \"sources\" must be an array");
  }

  const sources: SupportedSourceConfig[] = [];
  const unsupported: UnsupportedSourceConfig[] = [];

  for (let index = 0; index < rawSources.length; index++) {
    const rawSource = rawSources[index];
    if (!isRecord(rawSource)) {
      unsupported.push({ index, reason: "source entry must be an object", value: rawSource });
      continue;
    }

    const kind = typeof rawSource.kind === "string" ? rawSource.kind : undefined;

    if (kind === "mcp") {
      const parsedSource = parseMcpSource(rawSource);
      if (!parsedSource.source) {
        unsupported.push({ index, kind, reason: parsedSource.reason ?? "invalid mcp source", value: rawSource });
        continue;
      }
      sources.push(parsedSource.source);
      continue;
    }

    if (kind === "openapi") {
      const parsedSource = parseOpenApiSource(rawSource);
      if (!parsedSource.source) {
        unsupported.push({ index, kind, reason: parsedSource.reason ?? "invalid openapi source", value: rawSource });
        continue;
      }
      sources.push(parsedSource.source);
      continue;
    }

    if (kind === "graphql") {
      const parsedSource = parseGraphqlSource(rawSource);
      if (!parsedSource.source) {
        unsupported.push({ index, kind, reason: parsedSource.reason ?? "invalid graphql source", value: rawSource });
        continue;
      }
      sources.push(parsedSource.source);
      continue;
    }

    unsupported.push({
      index,
      kind,
      reason: kind ? "unsupported source kind: " + kind : "source.kind is required",
      value: rawSource,
    });
  }

  return { configPath, fingerprint, sources, unsupported };
};
