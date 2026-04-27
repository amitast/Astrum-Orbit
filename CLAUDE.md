# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Salesforce DX project** built with Lightning Web Components (LWC), Aura components, and Apex. It targets Salesforce API v66.0 and is configured for a Developer Edition org.

## Common Commands

```bash
# Lint Aura and LWC JavaScript
npm run lint

# Run Jest unit tests
npm test

# Run tests in watch mode
npm run test:unit:watch

# Run tests with coverage
npm run test:unit:coverage

# Format all files (Apex, LWC, CSS, HTML, JS, JSON, Markdown)
npm run prettier

# Verify formatting without changing files (CI-safe)
npm run prettier:verify
```

Pre-commit hooks run automatically via Husky — they execute `lint-staged` which formats and lints staged files before each commit.

## Architecture

The project follows standard Salesforce DX metadata structure under `force-app/main/default/`:

- **`lwc/`** — Lightning Web Components (modern UI framework; prefer for new UI work)
- **`aura/`** — Aura components (legacy UI framework)
- **`classes/`** — Apex classes (server-side business logic, exposed to LWC via `@wire` or `@AuraEnabled` methods)
- **`triggers/`** — Apex triggers (DML event handlers on Salesforce objects)
- **`objects/`** — Custom object and field definitions
- **`flexipages/`** — Lightning App Builder page layouts
- **`staticresources/`** — Static assets (CSS, JS libs, images)
- **`permissionsets/`** — Declarative access control definitions

### LWC Component Pattern

Each LWC component lives in its own folder under `lwc/` containing:
- `componentName.html` — template
- `componentName.js` — controller (ES modules, `import { LightningElement } from 'lwc'`)
- `componentName.js-meta.xml` — metadata (targets, API version, visibility)
- `componentName.css` — scoped styles (optional)
- `__tests__/componentName.test.js` — Jest tests (optional)

### Apex ↔ LWC Communication

Apex methods must be annotated `@AuraEnabled` to be callable from LWC. Use `@wire` for reactive data fetching, or `import` for imperative calls.

## Salesforce CLI

Deploy/retrieve metadata and manage scratch orgs via `sf` (Salesforce CLI v2) or `sfdx`:

```bash
# Push source to a scratch org
sf project deploy start

# Pull changes from org
sf project retrieve start

# Run Apex anonymously
sf apex run --file scripts/apex/hello.apex

# Run SOQL query
sf data query --file scripts/soql/account.soql
```

## Tooling Config

- **ESLint:** `eslint.config.js` — uses `@salesforce/eslint-config-lwc` for LWC files and `eslint-plugin-aura` for Aura; Jest globals are enabled for test files
- **Jest:** `jest.config.js` — uses `@salesforce/sfdx-lwc-jest` transformer; module name mapper provides stubs for `@salesforce/*`, `lightning/*`, and `c/*` namespaces
- **Prettier:** `.prettierrc` — trailing commas enabled; uses `prettier-plugin-apex` and `@prettier/plugin-xml`
- **Scratch Org:** `config/project-scratch-def.json` — Developer edition with Lightning Experience and `SetPasswordInApi` enabled

## Hard Rules

Every record-triggered flow MUST include bypass logic checking a 'Bypass_Flow' custom permission before executing.
Always append the flow type to the Flow Label and API Name (e.g., Set_Account_Active_After_Save).
Always include descriptions for any new custom fields, objects, validation rules, or Flow elements.
Never deploy metadata to a production environment. Deployments must always be restricted to Developer Sandboxes or Scratch Orgs

## Dual-Agent Coordination

This project uses a two-agent operating model. Full protocol: `docs/dual-agent-protocol.md`. Codex operating instructions: `AGENTS.md`.

### Claude Code (Architect) — this agent's responsibilities
- PRD authoring and approval
- Schema validation before any build starts
- Review of all Codex-produced metadata before Human approval
- Linear updates: requirement summary, PRD status, blockers, open decisions, review findings, recommended next step
- Does not implement Flow XML or run deployments

### Codex (Builder) — the other agent's responsibilities
- Flow XML implementation per approved PRD only
- Apex test class authoring and smoke test execution
- Linear updates: files changed, implementation summary, tests run, validation evidence, deploy ID, known risks
- Does not design, author PRDs, or make deployment decisions
- Governed by `AGENTS.md` — do not edit that file

### Human (Approver) — sole authority for
- All production deployments
- Linear status transitions to Done, Closed, or Production Ready
- Business decision sign-off (BD-01 through BD-10)
- Sandbox smoke test sign-off (7/7 scenarios required)
- Merge to main

### Linear governance (both agents)
- Read the current issue state before posting any update
- Additive comments only — never rewrite description unless explicitly instructed
- Every comment must include: agent name, date, action, evidence reference
- Neither agent may set status to Done, Closed, or Production Ready
