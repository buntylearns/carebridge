#!/usr/bin/env bash
# ============================================================
# CareBridge Curriculum -> GitHub Issues/Milestones importer
#
# Creates: 1 label per phase + type labels, 1 milestone per phase,
#          1 issue per lesson (completed lessons are auto-closed).
#
# Prereqs: gh CLI authenticated (you already are).
# Usage:   bash import-curriculum.sh            # imports into buntylearns/carebridge
#          bash import-curriculum.sh owner/repo # or another repo
#
# After it finishes, create the kanban board (one-time, ~1 min):
#   1. Run: gh auth refresh -s project   (adds the 'project' scope)
#   2. Run: gh project create --owner buntylearns --title "CareBridge Curriculum"
#   3. On github.com -> your profile -> Projects -> open the project
#      -> Settings -> Manage access (private is fine)
#      -> In the project, click "+ Add item" -> "Add from repository"
#         and bulk-add the carebridge issues (filter: is:issue).
#   4. Board columns: the default "Todo / In Progress / Done" map
#      perfectly to lessons; closed issues land in Done automatically.
#   Optional: in the project's Workflows, enable "Auto-add to project"
#   for repo carebridge so future issues appear automatically.
# ============================================================
set -euo pipefail

REPO="${1:-buntylearns/carebridge}"

# Retry helper: tries a command up to 3 times (GitHub 503s are transient)
retry() {
  local n
  for n in 1 2 3; do
    if "$@"; then return 0; fi
    echo "   (attempt $n failed, waiting 5s...)" >&2
    sleep 5
  done
  return 1
}

echo ">> Importing curriculum into $REPO"
echo ">> Checking gh auth..."
gh auth status >/dev/null

# ---------- Labels ----------
echo ">> Creating labels..."
for p in $(seq 0 14); do
  retry gh label create "phase-$p" --repo "$REPO" --color "0E8A16" --description "Curriculum Phase $p" --force >/dev/null 2>&1 || echo "   (label phase-$p skipped)"
done
retry retry gh label create "lesson" --repo "$REPO" --color "1D76DB" --description "One ~1h session" --force >/dev/null 2>&1 || echo "   (label lesson skipped)" 2>&1 || echo "   (label lesson skipped)"
retry gh label create "mini-project" --repo "$REPO" --color "5319E7" --description "Phase mini-project" --force >/dev/null 2>&1 || echo "   (label mini-project skipped)"
gh label create "homework"     --repo "$REPO" --color "FBCA04" --description "Between-session exercise" --force >/dev/null

# ---------- Milestones (one per phase) ----------
echo ">> Creating milestones..."
PHASE_TITLES=(
  "Phase 0 - Dev Environment, Git & GitHub"
  "Phase 1 - Java Fundamentals + JSON"
  "Phase 2 - Spring Boot: REST & GraphQL"
  "Phase 3 - MongoDB"
  "Phase 4 - Microservices, 3-Layer APIs & Docker"
  "Phase 5 - Kafka, Flowable & Drools"
  "Phase 6 - Neo4j"
  "Phase 7 - Testing & Playwright"
  "Phase 8 - CI/CD & DevSecOps Pipeline"
  "Phase 9 - Cloud & Kubernetes on Azure"
  "Phase 10 - AI & Agentic AI + reg-watch"
  "Phase 11 - Cybersecurity Deep Dive"
  "Phase 12 - Ontology Concepts (Foundry)"
  "Phase 13 - React Frontend + Analytics"
  "Phase 14 - Capstone: FHIR/HL7 + Production"
)
declare -a MS_TITLE
for p in $(seq 0 14); do
  title="${PHASE_TITLES[$p]}"
  # create if missing (gh api errors if duplicate title -> tolerate)
  gh api "repos/$REPO/milestones" -f title="$title" >/dev/null 2>&1 || true
  MS_TITLE[$p]="$title"
done

# ---------- Lessons ----------
# Format: phase|lesson|status|type|title
DATATMP="$(mktemp /tmp/carebridge-curriculum.XXXXXX)"
cat > "$DATATMP" <<'EOF'
0|0.1|done|lesson|Install Homebrew, JDK (Temurin 21), Maven, Git
0|0.2|done|lesson|VS Code + Extension Pack for Java
0|0.3|done|lesson|First Java program: compile (javac) and run (JVM)
0|0.4|done|lesson|Git fundamentals: init, .gitignore, staging, commit, main branch
0|0.5|done|lesson|Publish to GitHub: gh CLI auth, remote, first push
0|0.6|open|homework|Checkpoint: 3rd println, stale .class demo, recompile, commit & push
1|1.1|open|lesson|Variables, types, operators, control flow + first real README
1|1.2|open|lesson|Methods and classes: encapsulation, constructors
1|1.3|open|lesson|Inheritance, interfaces, polymorphism
1|1.4|open|lesson|Collections (List, Map, Set) and generics
1|1.5|open|lesson|Exceptions, records, streams & lambdas
1|1.6|open|lesson|JSON deep dive: syntax, Jackson, JSON Schema, JSON across the stack
1|1.7|open|mini-project|Console app: patient registry & eligibility check with JSON (FHIR shapes)
2|2.1|open|lesson|Spring Boot + Initializr; 12-factor principles
2|2.2|open|lesson|First REST controller (patients); Jackson auto-mapping
2|2.3|open|lesson|Dependency injection and the service layer
2|2.4|open|lesson|Validation, error handling, DTOs
2|2.5|open|lesson|PostgreSQL + SQL: tables, keys, joins, transactions; Spring Data JPA
2|2.6|open|lesson|Externalized config + Actuator health; gitleaks pre-commit (DevSecOps gate #1)
2|2.7|open|lesson|GraphQL vs REST: schema, queries, mutations
2|2.8|open|lesson|Spring for GraphQL alongside REST
2|2.9|open|mini-project|patient-service: REST + GraphQL on Postgres, probes, env config
3|3.1|open|lesson|Documents vs tables; BSON; FHIR shapes; polyglot persistence
3|3.2|open|lesson|MongoDB Community + Compass setup
3|3.3|open|lesson|Spring Data MongoDB: repositories, queries
3|3.4|open|lesson|Modeling: embedding vs referencing (patient/coverage/claims)
3|3.5|open|mini-project|patient-system-api on MongoDB with Synthea-style data
4|4.1|open|lesson|Monolith vs microservices; unified-platform vision; interoperability-first
4|4.2|open|lesson|3-layer API-led architecture: System / Process / Experience APIs
4|4.3|open|lesson|Build System layer: patient-, claims-, provider-system-api
4|4.4|open|lesson|Build Process layer: eligibility-process-api; Resilience4j patterns
4|4.5|open|lesson|Experience layer: Spring Cloud Gateway + GraphQL BFF; federation concepts
4|4.6|open|lesson|YAML deep dive: syntax, anchors, gotchas; YAML vs JSON
4|4.7|open|lesson|Docker deep dive: Dockerfiles, docker-compose runs the whole platform
5|5.1|open|lesson|Events vs sync; the logic trio: Kafka vs Flowable vs Drools
5|5.2|open|lesson|Kafka concepts: topics, partitions, producers, consumers, groups
5|5.3|open|lesson|Run Kafka locally via docker-compose
5|5.4|open|lesson|Spring Kafka: publish ClaimSubmitted (JSON payloads, schema evolution)
5|5.5|open|lesson|Adjudication consumer -> ClaimAdjudicated; delivery semantics
5|5.6|open|lesson|Outbox, idempotency, DLTs; GraphQL subscriptions for live claim status
5|5.7|open|lesson|Business rules: DMN decision tables, then Drools (facts, DRL, KIE)
5|5.8|open|lesson|Workflow engines & BPMN 2.0; Flowable in Spring Boot; Temporal comparison
5|5.9|open|lesson|Flowable + Drools: prior-authorization workflow with human tasks
5|5.10|open|mini-project|Claims adjudication end to end; rules editable without code changes
6|6.1|open|lesson|Graph thinking: nodes, relationships, properties
6|6.2|open|lesson|Cypher query language basics
6|6.3|open|lesson|Spring Data Neo4j in provider-system-api
6|6.4|open|mini-project|Provider network graph: referrals, in-network specialist search
7|7.1|open|lesson|Unit tests (JUnit) + integration tests (Testcontainers)
7|7.2|open|lesson|API testing per layer incl. Flowable processes and Drools rule tests
7|7.3|open|lesson|Playwright fundamentals
7|7.4|open|mini-project|Playwright suite for the React portal
8|8.1|open|lesson|CI/CD concepts; shift-left DevSecOps
8|8.2|open|lesson|GitHub Actions: build + test on every push/PR
8|8.3|open|lesson|Jenkins awareness: Jenkinsfile basics, enterprise context
8|8.4|open|lesson|Security gates: gitleaks, SCA, Semgrep SAST on every PR; triage
8|8.5|open|lesson|Full pipeline: build/test/gates -> Docker image -> Trivy -> registry
9|9.1|open|lesson|Cloud fundamentals; Azure account; Azure CLI deep dive; cost guardrails
9|9.2|open|lesson|Kubernetes concepts as YAML: pods, deployments, services, ingress
9|9.3|open|lesson|CareBridge on kind/minikube: probes, scaling, self-healing
9|9.4|open|lesson|AKS via Azure CLI: aks create, acr build; teardown ritual
9|9.5|open|lesson|Helm basics; Azure managed services tour (config swap, not code)
9|9.6|open|lesson|Azure Key Vault; Azure Monitor basics
9|9.7|open|lesson|Scripting: zsh/bash + PowerShell (pwsh, Az module); when each
9|9.8|open|lesson|CD to AKS from Actions; horizontal pod autoscaling
9|9.9|open|lesson|K8s security & policy-as-code: pod security, Kyverno, RBAC
10|10.1|open|lesson|How LLMs work: practical mental model
10|10.2|open|lesson|Python essentials (just enough)
10|10.3|open|lesson|Models: Ollama local + hosted APIs; Spring AI from Java
10|10.4|open|lesson|RAG fundamentals: embeddings, vector stores, retrieval
10|10.5|open|lesson|Agentic concepts: tools, loops, planning, memory
10|10.6|open|lesson|LangGraph: graphs, nodes, state, routing, human-in-the-loop
10|10.7|open|lesson|Decision-logic spectrum: Drools vs Flowable vs LangGraph
10|10.8|open|lesson|MCP server with FastMCP: check_eligibility, lookup_claim, find_provider
10|10.9|open|lesson|LangSmith: tracing, debugging, evals (Langfuse noted)
10|10.10|open|lesson|reg-watch 1: ingest Federal Register / CMS / eCFR; change detection
10|10.11|open|lesson|reg-watch 2: impact-analysis agent maps changes to rules, drafts updates
10|10.12|open|lesson|reg-watch 3: human approval via Flowable; audited rule updates
10|10.13|open|mini-project|Claims assistant + reg-watch demo: detect, propose, approve, adapt
10|10.14|open|lesson|AI-assisted development in VS Code
11|11.1|open|lesson|Threat modeling CareBridge; DevSecOps culture
11|11.2|open|lesson|OWASP Top 10 hands-on vs our own code
11|11.3|open|lesson|Spring Security, OAuth2/OIDC, JWT; roles; Entra ID
11|11.4|open|lesson|TLS, hashing vs encryption, bcrypt, encryption at rest
11|11.5|open|lesson|Secrets lifecycle: env, K8s secrets, Key Vault, rotation
11|11.6|open|lesson|Supply chain: SBOM (Syft), signing (cosign), SLSA
11|11.7|open|lesson|DAST with ZAP; rate limiting & edge validation
11|11.8|open|lesson|AI security: prompt injection (incl. poisoned regs vs reg-watch), MCP scoping
11|11.9|open|lesson|HIPAA, PHI handling, audit trails; controls-to-compliance mapping
12|12.1|open|lesson|Ontology: objects, links, actions; what Palantir Foundry is
12|12.2|open|lesson|CareBridge as an ontology in Neo4j; JSON-LD/RDF basics
12|12.3|open|lesson|Mapping back to Foundry (conceptual)
13|13.1|open|lesson|TypeScript essentials: types, interfaces, generics
13|13.2|open|lesson|React fundamentals: components, JSX, props, state; Vite
13|13.3|open|lesson|Hooks & data flow: useEffect, custom hooks, context
13|13.4|open|lesson|React Router, forms; Apollo Client to GraphQL; JWT auth
13|13.5|open|mini-project|Provider portal: lookup, live claims dashboard, prior-auth + reg-watch review UI
13|13.6|open|lesson|Angular in one lesson: concepts mapped to React
13|13.7|open|lesson|Product analytics concepts; Pendo vs PostHog vs others
13|13.8|open|lesson|Instrument portal with PostHog; map to Pendo equivalents
13|13.9|open|lesson|Containerize React; add to compose/K8s + CI/CD gates
14|14.1|open|lesson|Interoperability landscape: HL7 v2, CDA, why FHIR won; X12 EDI
14|14.2|open|lesson|FHIR fundamentals: core resources, bundles, profiles, US Core
14|14.3|open|lesson|HAPI FHIR: parse/validate/serialize; refactor to FHIR R4
14|14.4|open|lesson|FHIR REST API as Experience API; HAPI server exchange
14|14.5|open|lesson|Synthea FHIR bundles across the stack; rules on FHIR Claims
14|14.6|open|lesson|HL7 v2 hands-on: parse ADT, bridge v2 -> FHIR
14|14.7|open|lesson|CMS interoperability & prior-auth rules; SMART on FHIR
14|14.8|open|lesson|Observability: Actuator, Prometheus + Grafana
14|14.9|open|lesson|Production readiness: DevSecOps audit, performance, README polish
14|14.10|open|mini-project|Capstone review: the complete CareBridge platform
EOF

echo ">> Creating issues (this takes a few minutes)..."
created=0
while IFS='|' read -r phase num status type title; do
  [ -z "$phase" ] && continue
  ms="${MS_TITLE[$phase]}"
  full_title="$num $title"
  # Skip if an issue with this exact title already exists (safe re-runs)
  if gh issue list --repo "$REPO" --state all --search "in:title \"$num \"" --json title --jq '.[].title' 2>/dev/null | grep -qF "$full_title"; then
    echo "   skip (exists): $full_title"
    continue
  fi
  body="Curriculum lesson **$num** (Phase $phase).

**Session format:** ~10 min concept -> ~40 min hands-on -> ~10 min wrap-up.
**Definition of done:**
- [ ] Hands-on work completed
- [ ] Checkpoint exercise done
- [ ] Committed & pushed to GitHub
- [ ] README updated if install/run changed

Full curriculum lives in the Tech Tutor project (claude/curriculum-roadmap.md)."
  url=$(retry gh issue create --repo "$REPO" \
        --title "$full_title" \
        --body "$body" \
        --label "phase-$phase" --label "$type" \
        --milestone "$ms")
  if [ "$status" = "done" ]; then
    gh issue close "$url" --repo "$REPO" --comment "Completed in Session 0 (2026-08-14)." >/dev/null
    echo "   created+closed: $full_title"
  else
    echo "   created: $full_title"
  fi
  created=$((created+1))
  sleep 1   # be gentle with the API
done < "$DATATMP"
rm -f "$DATATMP"

echo ""
echo ">> Done. Created $created issues across 15 milestones."
echo ">> Next: create the kanban board (see comments at the top of this script)."
echo ">> Quick check: gh issue list --repo $REPO --label lesson --limit 5"
