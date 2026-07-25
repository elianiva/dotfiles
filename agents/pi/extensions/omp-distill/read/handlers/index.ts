/**
 * Protocol handler registry — re-exports all handlers for the read router.
 */
export type { ProtocolHandler, HandlerContext } from "./types";
export { httpHandler } from "./http";
export { skillHandler } from "./skill";
export { piDocHandler } from "./pi-docs";
export { issueHandler, prHandler } from "./github";
export { conflictHandler } from "./conflict";
