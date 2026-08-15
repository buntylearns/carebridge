# CareBridge

*(Carebridge is an opensource Healthcare Platform built for small Payers and Providers. It is built on modern tech stack with solid principles (more details to come). A learning
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