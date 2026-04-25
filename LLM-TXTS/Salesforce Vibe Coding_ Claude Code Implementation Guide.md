Executive SummaryThis guide establishes the operating model for "vibe coding" 
(AI-assisted development) on the Salesforce platform using Claude Code within Visual 
Studio Code. Designed for Salesforce administrators, developers, and architects, this 
document outlines how to safely and efficiently automate configuration, write code, refactor 
legacy systems, and enforce data quality. By combining Claude Code's agentic reasoning 
with the Salesforce CLI and Model Context Protocol (MCP), delivery teams can radically 
reduce administrative overhead while maintaining strict enterprise governance 1-3. 
1. What Vibe Coding Means in a Salesforce Context 
In a Salesforce context, "vibe coding" refers to using conversational AI to interact directly 
with your codebase and org metadata to execute tasks. Claude Code operates within your 
local environment, meaning it can read files, run Salesforce CLI commands, and query live 
schema via MCP 3, 4. 
For Salesforce delivery teams, Claude Code can: 
● Configure: Scaffold custom objects, fields, and validation rules 5, 6. 
● Develop: Build Lightning Web Components (LWC), Apex classes, and complex 
automations 7, 8. 
● Test: Write characterisation tests to capture existing behaviour before refactoring 
legacy code 9. 
● Troubleshoot: Analyse deployment errors, debug flows, and run security audits 10, 
11. 
● Document: Generate Product Requirements Documents (PRDs), handoff notes, and 
release notes 12, 13. 
2. Setup and Prerequisites 
To create a secure and integrated environment, follow this setup sequence: 
1. 
Salesforce CLI & Git: Ensure sf (Salesforce CLI) and Git are installed on your 
machine 14. 
2. 
3. 
4. 
5. 
6. 
7. 
VS Code & Extensions: Install Visual Studio Code. Download the Salesforce 
Extension Pack 15. 
Salesforce DX Project: Create a project using the CLI (e.g., sf project generate -n 
my-project) and open it in VS Code 16, 17. 
Claude Code Extension: Install the Claude Code extension from the VS Code 
Marketplace. Sign in using your Anthropic account 18-21. 
MCP Connection: Configure the Salesforce DX MCP server so Claude Code can 
query your org's schema and run CLI commands without hallucinating 3, 22. 
Initialise Context: Run /init in the Claude Code prompt to generate a CLAUDE.md 
file. This acts as the "brain" and persistent memory for the project, housing your hard 
rules 16, 23, 24. 
Recommended Folder Structure: Create folders named LLM-TXTS (to store 
relevant Salesforce documentation for context) and PRDS (to store 
Claude-generated implementation plans) 7, 13. 
3. Recommended Working Method 
Do not let Claude Code run wild. The fastest way to break a production environment is 
executing a "big bang" refactor 25, 26. Follow this incremental method: 
1. 
Understand & Contextualise: Place relevant documentation in your LLM-TXTS 
folder and ask Claude to read it using @ mentions 7, 27. 
2. 
3. 
4. 
5. 
6. 
7. 
Generate a PRD: Ask Claude to produce an implementation plan (PRD) and save it 
in the PRDS folder before writing any code 28, 29. 
Baseline Testing: If modifying existing logic, prompt Claude to write characterisation 
tests first. These capture the current behaviour so you can detect regressions 9. 
Incremental Execution: Ask Claude to execute the PRD step-by-step 26. 
Review Diffs: VS Code will show a side-by-side comparison of proposed changes. 
Review these natively in the IDE 30. 
Test & Deploy: Run unit tests. Deploy changes to your Developer Sandbox or 
Scratch Org using Salesforce CLI 31-33. 
Handoff Documentation: Ask Claude to generate a short handoff document noting 
what changed, what was skipped, and known edge cases 12, 34. 
4. Salesforce Admin Use Cases 
4.1 Validation Rules & Custom Objects 
● When to use: Rapidly scaffolding new data models or enforcing data quality logic 5, 
6. 
● Example prompt: "Read the PRD in @PRDS/opportunity_tracking.md. Create a 
custom object for Competitor Information with a lookup to Opportunity. Then, create a 
validation rule ensuring Opportunities in 'Negotiation' have a minimum amount." 5, 6 
● Human review checklist: Check field data types, verify lookup relationship 
configurations, and confirm the validation rule error location 5, 6. 
● Key risks: Exceeding edition limits for custom fields or bypassing existing managed 
package dependencies 35. 
4.2 Flow Design 
● When to use: Translating business logic into automations (e.g., Record-Triggered 
Flows) 36. 
● Example prompt: "Create a Before-Save Record-Triggered Flow named 
'Set_Account_Active_Before_Save'. It must check the 'Bypass_Flow' custom 
permission first. If not bypassed, update the Account Status to Active when a related 
Opportunity is Closed Won." 37, 38 
● Human review checklist: Ensure bypass logic is present, naming conventions are 
followed, and fault paths are included 37, 38. 
● Key risks: Unintended recursion, missing bypass logic causing data load failures, 
and updating records outside the user's sharing context 37, 39. 
4.3 Org Auditing 
● When to use: Running periodic health checks on technical debt, security, and 
automation 10, 40-42. 
● Example prompt: "Use MCP to query the org. Identify any profiles with 'Modify All 
Data', active users with no login in 90 days, and list all active Workflow Rules." 42, 43 
● Human review checklist: Validate the returned list against known integration users 
who may require elevated permissions. 
● Key risks: AI misinterpreting missing data as a vulnerability. Ensure the running user 
has sufficient read permissions (System Administrator) to query security 
configurations 44. 
5. Salesforce Developer Use Cases 
5.1 Legacy Refactoring 
● Recommended workflow: Write characterisation tests -> Define boundaries in 
CLAUDE.md -> Refactor incrementally -> Run tests -> Run CodeRabbit or external 
review 9, 23, 26, 45-47. 
● Example prompt: "Generate minimal pytest characterisation tests for 
@legacy_billing.cls. Focus on capturing current outputs given realistic inputs. No 
behaviour changes, just document what this code actually does right now." 9 
● Testing requirements: 100% pass rate on characterisation tests before and after the 
refactor 26. 
● Common failure modes: Claude hallucinating APIs or methods that do not exist in 
your codebase 12, 47. 
5.2 Lightning Web Components (LWC) 
● Recommended workflow: Provide Salesforce documentation in LLM-TXTS, prompt 
for a plan, generate the HTML/JS/XML files, and test locally 7, 13, 28, 48. 
● Example prompt: "Create an LWC for the Account record page that calculates the 
distance between the Account's shipping address and the user's location. Review 
@LLM-TXTS/location_class.md first. Present a plan before coding." 28 
● Testing requirements: Ensure UI behaves properly within the Lightning container 
and recalculate buttons do not break CSS boundaries 49. 
● Common failure modes: Hardcoding CSS instead of using Salesforce Lightning 
Design System (SLDS) utility classes 50. 
5.3 Apex & SOQL Security 
● Recommended workflow: Generate queries or DML operations and explicitly 
instruct Claude to enforce security 51. 
● Example prompt: "Write an Apex method to retrieve Opportunity records and update 
the Amount field. You must enforce CRUD, FLS, and Sharing Rules using the WITH 
USER_MODE syntax." 51 
● Testing requirements: Run tests as a low-privileged user using System.runAs() to 
ensure FLS exceptions are thrown appropriately 52. 
● Common failure modes: Silent CRUD/FLS vulnerabilities due to running in System 
Mode 53. 
6. Flow, Agentforce, and Automation Best Practices 
6.1 Flow Governance 
● Bypass Logic: Every record-triggered flow must include bypass logic evaluating a 
Custom Permission (e.g., Bypass_Flows) to prevent unintended execution during 
data loads 37. 
● Naming Conventions: Always append the flow type to the Label and API Name 
(e.g., Update_Contact_After_Save) 38. 
● Audit Naming: If a Flow is invoked by Agentforce, prefix it with AGENT_ for tracking 
in Shield Event Monitoring 54. 
● Run Mode: Flows triggered by agents must run in User Context to respect sharing 
rules, not System Context 55, 56. 
6.2 Agentforce Design 
● Subagent Boundaries: Write sharp, non-overlapping subagent descriptions. The 
Atlas Reasoning Engine uses these descriptions as classification prompts to route 
user intent 57, 58. 
● Human-in-the-Loop (HITL): Standardise on Confirm HITL mode for any action that 
writes or modifies data. Never execute bulk updates without explicit, per-record user 
confirmation 54, 59. 
● Instruction vs. Guardrails: Instructions are interpreted by the LLM and are 
non-deterministic. Critical rules (e.g., "Never delete a record") must be enforced by 
non-LLM controls, such as permission sets that omit Delete access 59, 60. 
● Testing: Build a 50-prompt regression baseline suite to test agent routing and 
behaviour before any model update goes to production 61, 62. 
7. Prompt Library 
Use these tested prompts to drive predictable outcomes. 
Initialising Project Context 
"Analyse this Salesforce DX project structure. Generate a CLAUDE.md file containing strict 
naming conventions for Flows and Apex, the requirement to use WITH USER_MODE for all 
SOQL, and mandatory bypass logic for all triggers. Save it in the root directory." 16, 23, 51 
Creating an Implementation Plan (PRD) 
"Review the requirement in @requirements.txt. Create a comprehensive Product 
Requirements Document (PRD) detailing the proposed Apex, LWC, and Custom Objects 
required. Save this to the @PRDS folder. Do not write code yet." 28, 29, 48 
Building Test Classes 
"Write a unit test for @MyApexClass.cls. Create all necessary test data before calling 
Test.startTest(). Exercise bulk functionality with at least 20 records. Implement 
System.Assert methods to prove expected outcomes. Ensure coverage is above 75%." 52 
Agentforce Instruction Generation 
"Write instructions for a Salesforce Agentforce subagent that handles Account management. 
Include instructions to always retrieve the record before proposing an update, and to verify 
potential duplicate contacts using first and last name before creating new ones." 63, 64 
Reviewing Code / Explaining Deployment Errors 
"Review @MyBrokenClass.cls and the deployment error log in @terminal:DeployLog. 
Identify the root cause of the failure and propose a fix. Ensure your fix complies with the 
rules in CLAUDE.md." 11, 65 
8. Safety and Governance 
● Human Review is Mandatory: Claude Code is an assistant, not an autonomous 
deployer. Review diffs carefully before accepting 33, 66. 
● Sandbox Only: Restrict all Claude Code deployment commands to Developer 
Sandboxes or Scratch Orgs 32, 33. 
● Enforce User Mode: Always instruct Claude to use WITH USER_MODE or 
AccessLevel.USER_MODE in Apex to enforce sharing and FLS automatically 51. 
● Protect PII: Do not pass raw free-text fields (like Description or Notes) directly into 
Prompt Templates to avoid prompt injection attacks. Utilise the Einstein Trust Layer 
to mask PII 67, 68. 
● Small Commits: Commit code to Git frequently using Git worktrees or branches. If 
Claude makes a mistake, you can easily revert isolated changes 26, 69, 70. 
● Checkpoints: Use VS Code's checkpoint feature to rewind code to a specific 
conversation state if an implementation plan goes off track 71. 
9. Anti-Patterns (What Not to Do) 
● The "Big Bang" Refactor: Pointing Claude at a messy 50,000-line codebase and 
asking it to "clean it up" will result in broken code and hours of untangling. Break 
tasks into small chunks 25, 26. 
● Ignoring Characterisation Tests: Changing legacy code without first asking Claude 
to write tests to lock down current behaviour 9. 
● Accepting Code Blindly: Using "auto-accept" mode without reviewing the 
generated logic, particularly for security access 72. 
● Trusting Hallucinated APIs: Assuming a method Claude called actually exists. 
Always rely on test execution or linters (like Salesforce Code Analyzer) to verify 12, 
50. 
● Missing Context: Failing to set up CLAUDE.md. Without it, the AI will generate 
generic Salesforce code rather than adhering to your specific architectural 
load-bearing rules 23, 24. 
10. Final Recommended Operating Model 
To successfully scale vibe coding across your Salesforce delivery team: 
1. 
Standardise the Environment: Mandate the use of VS Code, Salesforce CLI, the 
Claude Code extension, and the Salesforce DX MCP server for all builders 17, 22, 
24, 73-76. 
2. 
3. 
4. 
5. 
Codify the Brain: Maintain a central, version-controlled CLAUDE.md file that 
cascades down to specific app directories, locking in your org's non-negotiable 
standards 45, 46. 
Shift Left on Security: Run the Salesforce Code Analyzer locally on all 
AI-generated code to catch FLS violations before pull requests 50. 
Embrace the PRD Workflow: Train BAs and Developers to ask Claude for an 
implementation plan first, review the plan together, and then unleash Claude to write 
the code 28. 
Test-Driven Execution: AI writes the tests, the AI writes the code to pass the tests, 
and the Human reviews the outcome 9, 66. 