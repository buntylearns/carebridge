# CareBridge

*(you: 2–3 sentences — what CareBridge is and where it's headed. A learning
project building a healthcare provider–payor platform, step by step, from
first Java program to cloud-native microservices. Say it your way.)*

## Status

Phase 1 — Java fundamentals. Current programs:

- `HelloCareBridge.java` — first program, prints a greeting
- `ClaimCheck.java` — mini claim adjudicator: applies a deductible across
  a day of claims and totals what the plan paid

## Prerequisites

- Java 21 (JDK) — check with `java -version`
- Git

## Run it

```
git clone https://github.com/buntylearns/carebridge.git
cd carebridge
javac ClaimCheck.java
java ClaimCheck
```