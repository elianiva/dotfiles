/**
 * Ask Tool Extension
 *
 * Provides an interactive Q&A tool for the LLM to ask users questions
 * with multiple choice options or free-form text input.
 */

import type { ExtensionAPI, ToolResult } from "@mariozechner/pi-coding-agent";
import { Key, matchesKey, truncateToWidth } from "@mariozechner/pi-tui";
import { Type } from "@sinclair/typebox";

// Ask tool option schema
const AskOptionSchema = Type.Object({
	label: Type.String({ description: "Display label for the option" }),
	description: Type.Optional(Type.String({ description: "Optional description shown below label" })),
});

const AskQuestionSchema = Type.Object({
	question: Type.String({ description: "The question to ask the user" }),
	options: Type.Array(AskOptionSchema, { description: "Options for the user to choose from" }),
	shortTitle: Type.Optional(Type.String({ description: "Short 1-2 word title for tab display (defaults to number)" })),
});

// Single object with everything optional to avoid union issues
const AskParams = Type.Object({
	questions: Type.Optional(Type.Array(AskQuestionSchema, { description: "A list of questions to ask the user" })),
	question: Type.Optional(Type.String({ description: "The question to ask the user" })),
	options: Type.Optional(Type.Array(AskOptionSchema, { description: "Options for the user to choose from" })),
});

interface AskDetails {
	question: string;
	options: string[];
	answer: string | null;
	wasCustom?: boolean;
}

interface MultiAskDetails {
	results: AskDetails[];
}

interface QuestionState {
	optionIndex: number;
	editMode: boolean;
	customAnswer: string;
	answer: string | null;
	wasCustom: boolean;
}

export default function askToolExtension(pi: ExtensionAPI): void {
	pi.registerTool({
		name: "ask",
		label: "Ask",
		description: "Ask the user one or more questions and let them pick from options or type a custom answer. Use when you need user input to proceed with a decision.",
		parameters: AskParams,

		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			const questions: { question: string; options: { label: string; description?: string }[]; shortTitle?: string }[] = [];

			if (params.questions && params.questions.length > 0) {
				questions.push(...params.questions);
			} else if (params.question && params.options) {
				questions.push({ question: params.question, options: params.options });
			}

			if (questions.length === 0) {
				return {
					content: [{ type: "text", text: "Error: No questions (or question/options) provided" }],
				};
			}

			if (!ctx.hasUI) {
				return {
					content: [{ type: "text", text: "Error: UI not available (running in non-interactive mode)" }],
					details: {
						results: questions.map((q) => ({
							question: q.question,
							options: q.options.map((o) => o.label),
							answer: null,
						})),
					} as MultiAskDetails,
				};
			}

			// Single question: use simple flow (no tabs, no review)
			if (questions.length === 1) {
				return handleSingleQuestion(ctx, questions[0]);
			}

			// Multiple questions: use tabbed UI with review
			return handleMultipleQuestions(ctx, questions);
		},
	});
}

async function handleSingleQuestion(
	ctx: ExtensionAPI["ctx"],
	q: { question: string; options: { label: string; description?: string }[]; shortTitle?: string },
): Promise<ToolResult> {
	const allOptions = [
		...q.options,
		{ label: "Type your own answer", description: "Write a custom response" },
	];

	const result = await ctx.ui.custom<{ answer: string; wasCustom: boolean; index?: number } | null>(
		(tui, theme, _kb, done) => {
			let optionIndex = 0;
			let editMode = false;
			let customAnswer = "";
			let cachedLines: string[] | undefined;

			function refresh() {
				cachedLines = undefined;
				tui.requestRender();
			}

			function handleInput(data: string) {
				if (editMode) {
					if (matchesKey(data, Key.escape)) {
						editMode = false;
						customAnswer = "";
						refresh();
						return;
					}
					if (matchesKey(data, Key.enter)) {
						const trimmed = customAnswer.trim();
						if (trimmed) {
							done({ answer: trimmed, wasCustom: true });
						} else {
							editMode = false;
							customAnswer = "";
							refresh();
						}
						return;
					}
					if (matchesKey(data, Key.backspace)) {
						customAnswer = customAnswer.slice(0, -1);
						refresh();
						return;
					}
					if (data.length === 1 && data.charCodeAt(0) >= 32) {
						customAnswer += data;
						refresh();
					}
					return;
				}

				if (matchesKey(data, Key.up)) {
					optionIndex = Math.max(0, optionIndex - 1);
					refresh();
					return;
				}
				if (matchesKey(data, Key.down)) {
					optionIndex = Math.min(allOptions.length - 1, optionIndex + 1);
					refresh();
					return;
				}
				if (matchesKey(data, Key.enter)) {
					const selected = allOptions[optionIndex];
					const isLastOption = optionIndex === allOptions.length - 1;
					if (isLastOption) {
						editMode = true;
						refresh();
					} else {
						done({ answer: selected.label, wasCustom: false, index: optionIndex + 1 });
					}
					return;
				}
				if (matchesKey(data, Key.escape)) {
					done(null);
				}
			}

			function render(width: number): string[] {
				if (cachedLines) return cachedLines;

				const lines: string[] = [];
				const add = (s: string) => lines.push(truncateToWidth(s, width));

				// Top border
				add(theme.fg("accent", "─".repeat(width)));

				// Question
				add(theme.fg("text", ` ${q.question}`));
				lines.push("");

				// Options
				for (let i = 0; i < allOptions.length; i++) {
					const opt = allOptions[i];
					const selected = i === optionIndex;
					const isLast = i === allOptions.length - 1;
					const prefix = selected ? theme.fg("accent", "> ") : "  ";
					const num = `${i + 1}.`;

					if (isLast && editMode) {
						add(prefix + theme.fg("accent", `${num} ${opt.label} ✎`));
					} else if (selected) {
						add(prefix + theme.fg("accent", `${num} ${opt.label}`));
					} else {
						add(`  ${theme.fg("text", `${num} ${opt.label}`)}`);
					}

					if (opt.description) {
						add(`     ${theme.fg("muted", opt.description)}`);
					}
				}

				if (editMode) {
					lines.push("");
					add(theme.fg("muted", " Your answer:"));
					const inputLine = ` > ${customAnswer}_`;
					add(truncateToWidth(inputLine, width));
				}

				// Help text
				lines.push("");
				const k = (s: string) => theme.bold(theme.fg("accent", s));
				const l = (s: string) => theme.fg("dim", s);
				if (editMode) {
					add(` ${k("enter")}${l(" submit • ")}${k("esc")}${l(" go back")}`);
				} else {
					add(` ${k("↑↓")}${l(" select • ")}${k("enter")}${l(" submit • ")}${k("esc")}${l(" dismiss")}`);
				}

				// Bottom border
				add(theme.fg("accent", "─".repeat(width)));

				cachedLines = lines;
				return lines;
			}

			return {
				render,
				invalidate: () => {
					cachedLines = undefined;
				},
				handleInput,
			};
		},
	);

	if (!result) {
		return {
			content: [{ type: "text", text: "User cancelled the question" }],
			details: {
				results: [{ question: q.question, options: q.options.map((o) => o.label), answer: null }],
			} as MultiAskDetails,
		};
	}

	return {
		content: [{ type: "text", text: result.wasCustom ? `User answered: ${result.answer}` : `User selected: ${result.answer}` }],
		details: {
			results: [
				{
					question: q.question,
					options: q.options.map((o) => o.label),
					answer: result.answer,
					wasCustom: result.wasCustom,
				},
			],
		} as MultiAskDetails,
	};
}

async function handleMultipleQuestions(
	ctx: ExtensionAPI["ctx"],
	questions: { question: string; options: { label: string; description?: string }[]; shortTitle?: string }[],
): Promise<ToolResult> {
	// Initialize state for each question
	const states: QuestionState[] = questions.map(() => ({
		optionIndex: 0,
		editMode: false,
		customAnswer: "",
		answer: null as string | null,
		wasCustom: false,
	}));

	let currentQuestion = 0;
	let inReview = false;
	let reviewOptionIndex = 0; // 0 = go back, 1 = submit

	const result = await ctx.ui.custom<{ results: { answer: string; wasCustom: boolean }[] } | null>(
		(tui, theme, _kb, done) => {
			let cachedLines: string[] | undefined;

			function refresh() {
				cachedLines = undefined;
				tui.requestRender();
			}

			function getCurrentOptions() {
				const q = questions[currentQuestion];
				return [
					...q.options,
					{ label: "Type your own answer", description: "Write a custom response" },
				];
			}

			function handleInput(data: string) {
				if (inReview) {
					handleReviewInput(data);
					return;
				}

				const state = states[currentQuestion];
				const allOptions = getCurrentOptions();

				if (state.editMode) {
					if (matchesKey(data, Key.escape)) {
						state.editMode = false;
						state.customAnswer = "";
						refresh();
						return;
					}
					if (matchesKey(data, Key.enter)) {
						const trimmed = state.customAnswer.trim();
						if (trimmed) {
							state.answer = trimmed;
							state.wasCustom = true;
							state.editMode = false;
							// Auto-advance to next question or review
							if (currentQuestion < questions.length - 1) {
								currentQuestion++;
							} else {
								inReview = true;
							}
							refresh();
						} else {
							state.editMode = false;
							state.customAnswer = "";
							refresh();
						}
						return;
					}
					if (matchesKey(data, Key.backspace)) {
						state.customAnswer = state.customAnswer.slice(0, -1);
						refresh();
						return;
					}
					if (data.length === 1 && data.charCodeAt(0) >= 32) {
						state.customAnswer += data;
						refresh();
					}
					return;
				}

				// Tab navigation between questions
				if (matchesKey(data, Key.tab)) {
					currentQuestion = (currentQuestion + 1) % questions.length;
					refresh();
					return;
				}
				if (matchesKey(data, Key.shift(Key.tab))) {
					currentQuestion = (currentQuestion - 1 + questions.length) % questions.length;
					refresh();
					return;
				}

				// Option selection within current question
				if (matchesKey(data, Key.up)) {
					state.optionIndex = Math.max(0, state.optionIndex - 1);
					refresh();
					return;
				}
				if (matchesKey(data, Key.down)) {
					state.optionIndex = Math.min(allOptions.length - 1, state.optionIndex + 1);
					refresh();
					return;
				}
				if (matchesKey(data, Key.enter)) {
					const selected = allOptions[state.optionIndex];
					const isLastOption = state.optionIndex === allOptions.length - 1;
					if (isLastOption) {
						state.editMode = true;
						refresh();
					} else {
						state.answer = selected.label;
						state.wasCustom = false;
						// Auto-advance to next question or review
						if (currentQuestion < questions.length - 1) {
							currentQuestion++;
						} else {
							inReview = true;
						}
						refresh();
					}
					return;
				}
				if (matchesKey(data, Key.escape)) {
					done(null);
				}
			}

			function handleReviewInput(data: string) {
				if (matchesKey(data, Key.left) || matchesKey(data, Key.up)) {
					reviewOptionIndex = 0;
					refresh();
					return;
				}
				if (matchesKey(data, Key.right) || matchesKey(data, Key.down)) {
					reviewOptionIndex = 1;
					refresh();
					return;
				}
				if (matchesKey(data, Key.enter)) {
					if (reviewOptionIndex === 0) {
						// Go back to edit
						inReview = false;
						currentQuestion = 0;
						refresh();
					} else {
						// Submit
						done({
							results: states.map((s) => ({
								answer: s.answer!,
								wasCustom: s.wasCustom,
							})),
						});
					}
					return;
				}
				if (matchesKey(data, Key.escape)) {
					inReview = false;
					refresh();
				}
			}

			function render(width: number): string[] {
				if (cachedLines) return cachedLines;

				if (inReview) {
					return renderReview(width);
				}
				return renderQuestion(width);
			}

			function renderQuestion(width: number): string[] {
				const lines: string[] = [];
				const add = (s: string) => lines.push(truncateToWidth(s, width));
				const state = states[currentQuestion];
				const q = questions[currentQuestion];
				const allOptions = getCurrentOptions();

				// Tab bar with short titles (fallback to numbers)
				const tabs = questions.map((q, i) => {
					const isActive = i === currentQuestion;
					const isAnswered = states[i].answer !== null;
					const label = q.shortTitle || `${i + 1}`;
					if (isActive) {
						return theme.fg("accent", theme.bold(`[${label}]`));
					}
					if (isAnswered) {
						return theme.fg("muted", `[${label}✓]`);
					}
					return theme.fg("dim", `[${label}]`);
				});
				add(tabs.join(" "));

				// Top border
				add(theme.fg("accent", "─".repeat(width)));

				// Question
				add(theme.fg("text", ` ${q.question}`));
				lines.push("");

				// Options
				for (let i = 0; i < allOptions.length; i++) {
					const opt = allOptions[i];
					const selected = i === state.optionIndex;
					const isLast = i === allOptions.length - 1;
					const prefix = selected ? theme.fg("accent", "> ") : "  ";
					const num = `${i + 1}.`;
					const isActive = !isLast && state.answer === opt.label;
					const check = isActive ? ` ${theme.fg("accent", "✓")}` : "";

					if (isLast && state.editMode) {
						add(prefix + theme.fg("accent", `${num} ${opt.label} ✎`));
					} else if (isLast && state.wasCustom && state.answer) {
						add(prefix + (selected ? theme.fg("accent", `${num} ${opt.label}`) : theme.fg("text", `${num} ${opt.label}`)) + ` ${theme.fg("accent", "✓")}`);
					} else if (selected) {
						add(prefix + theme.fg("accent", `${num} ${opt.label}`) + check);
					} else {
						add(`  ${theme.fg("text", `${num} ${opt.label}`)}` + check);
					}

					if (opt.description) {
						add(`     ${theme.fg("muted", opt.description)}`);
					}
				}

				if (state.editMode) {
					lines.push("");
					add(theme.fg("muted", " Your answer:"));
					const inputLine = ` > ${state.customAnswer}_`;
					add(truncateToWidth(inputLine, width));
				}

				// Help text
				lines.push("");
				const k = (s: string) => theme.bold(theme.fg("accent", s));
				const l = (s: string) => theme.fg("dim", s);
				if (state.editMode) {
					add(` ${k("enter")}${l(" submit • ")}${k("esc")}${l(" go back")}`);
				} else {
					add(` ${k("↑↓")}${l(" select • ")}${k("tab")}${l(" next question • ")}${k("enter")}${l(" submit • ")}${k("esc")}${l(" dismiss")}`);
				}

				// Bottom border
				add(theme.fg("accent", "─".repeat(width)));

				cachedLines = lines;
				return lines;
			}

			function renderReview(width: number): string[] {
				const lines: string[] = [];
				const add = (s: string) => lines.push(truncateToWidth(s, width));

				// Header
				add(theme.fg("accent", theme.bold(" Review your answers")));
				add(theme.fg("accent", "─".repeat(width)));
				lines.push("");

				// Questions and answers
				for (let i = 0; i < questions.length; i++) {
					const q = questions[i];
					const state = states[i];
					const label = q.shortTitle || `Q${i + 1}`;
					add(` ${theme.fg("text", theme.bold(`${label}:`))} ${theme.fg("text", q.question)}`);
					if (state.answer) {
						const prefix = state.wasCustom ? "✎" : "✓";
						add(`   ${theme.fg("accent", prefix)} ${theme.fg("text", state.answer)}`);
					} else {
						add(`   ${theme.fg("dim", "○ No answer")}`);
					}
					lines.push("");
				}

				// Action buttons
				const goBackLabel = "← Go back to edit";
				const submitLabel = "Submit answers →";
				const goBack = reviewOptionIndex === 0
					? theme.fg("accent", theme.bold(`> ${goBackLabel}`))
					: theme.fg("dim", `  ${goBackLabel}`);
				const submit = reviewOptionIndex === 1
					? theme.fg("accent", theme.bold(`> ${submitLabel}`))
					: theme.fg("dim", `  ${submitLabel}`);
				add(` ${goBack}`);
				add(` ${submit}`);

				// Help text
				lines.push("");
				const k = (s: string) => theme.bold(theme.fg("accent", s));
				const l = (s: string) => theme.fg("dim", s);
				add(` ${k("←→")}${l(" select • ")}${k("enter")}${l(" confirm • ")}${k("esc")}${l(" go back")}`);

				// Bottom border
				add(theme.fg("accent", "─".repeat(width)));

				cachedLines = lines;
				return lines;
			}

			return {
				render,
				invalidate: () => {
					cachedLines = undefined;
				},
				handleInput,
			};
		},
	);

	if (!result) {
		return {
			content: [{ type: "text", text: "User cancelled the questions" }],
			details: {
				results: questions.map((q, i) => ({
					question: q.question,
					options: q.options.map((o) => o.label),
					answer: states[i].answer,
				})),
			} as MultiAskDetails,
		};
	}

	// Format output
	const outputText = questions
		.map((q, i) => {
			const r = result.results[i];
			const prefix = r.wasCustom ? "Answered" : "Selected";
			const label = q.shortTitle || `Question ${i + 1}`;
			return `${label}: ${q.question}\n${prefix}: ${r.answer}`;
		})
		.join("\n\n");

	return {
		content: [{ type: "text", text: outputText }],
		details: {
			results: questions.map((q, i) => ({
				question: q.question,
				options: q.options.map((o) => o.label),
				answer: result.results[i].answer,
				wasCustom: result.results[i].wasCustom,
			})),
		} as MultiAskDetails,
	};
}
