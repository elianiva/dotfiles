import { applyOutputFilters } from "../filter-engine";
import { splitCommandSegments } from "./shared";
import { ansiblePlaybookFilter } from "./ansible-playbook";
import { basedpyrightFilter } from "./basedpyright";
import { biomeFilter } from "./biome";
import { brewInstallFilter } from "./brew-install";
import { composerInstallFilter } from "./composer-install";
import { dotnetBuildFilter } from "./dotnet-build";
import { gccFilter } from "./gcc";
import { gcloudFilter } from "./gcloud";
import { hadolintFilter } from "./hadolint";
import { jjFilter } from "./jj";
import { jqFilter } from "./jq";
import { makeFilter } from "./make";
import { markdownlintFilter } from "./markdownlint";
import { mixCompileFilter } from "./mix-compile";
import { mixFormatFilter } from "./mix-format";
import { mvnBuildFilter } from "./mvn-build";
import { oxlintFilter } from "./oxlint";
import { pingFilter } from "./ping";
import { preCommitFilter } from "./pre-commit";
import { psFilter } from "./ps";
import { rsyncFilter } from "./rsync";
import { shellcheckFilter } from "./shellcheck";
import { sopsFilter } from "./sops";
import { sshFilter } from "./ssh";
import { statFilter } from "./stat";
import { swiftBuildFilter } from "./swift-build";
import { systemctlStatusFilter } from "./systemctl-status";
import { terraformPlanFilter } from "./terraform-plan";
import { tyFilter } from "./ty";
import { uvSyncFilter } from "./uv-sync";
import { xcodebuildFilter } from "./xcodebuild";
import { yamllintFilter } from "./yamllint";
import type { BashFilterSpec } from "./types";

export const BUILTIN_FILTERS: BashFilterSpec[] = [
  ansiblePlaybookFilter,
  basedpyrightFilter,
  biomeFilter,
  brewInstallFilter,
  composerInstallFilter,
  dotnetBuildFilter,
  gccFilter,
  gcloudFilter,
  hadolintFilter,
  jjFilter,
  jqFilter,
  makeFilter,
  markdownlintFilter,
  mixCompileFilter,
  mixFormatFilter,
  mvnBuildFilter,
  oxlintFilter,
  pingFilter,
  preCommitFilter,
  psFilter,
  rsyncFilter,
  shellcheckFilter,
  sopsFilter,
  sshFilter,
  statFilter,
  swiftBuildFilter,
  systemctlStatusFilter,
  terraformPlanFilter,
  tyFilter,
  uvSyncFilter,
  xcodebuildFilter,
  yamllintFilter,
];

export function findFilterForSegment(segment: string): BashFilterSpec | undefined {
  return BUILTIN_FILTERS.find((filter) => filter.matchCommand.test(segment));
}

export function applyBashCommandFilters(commandInput: string, output: string): string {
  let result = output;
  for (const segment of splitCommandSegments(commandInput)) {
    const filter = findFilterForSegment(segment);
    if (!filter) continue;
    result = applyOutputFilters(result, filter.filters);
  }
  return result;
}
