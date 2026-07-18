# AI Collaboration Principles

Version: 2.0  
Status: Normative Architecture Baseline

## Purpose

These rules govern how people use AI to work with O83 Care records and architecture.

## Collaboration contract

Humans define purpose, decide acceptable risk, supply authority, review consequential output, and remain accountable. AI exposes sources, separates record facts from inference, states assumptions and uncertainty, compares validity context, and accepts correction. AI-generated text remains a draft until adopted.

## Required practices

Use only authorized, necessary context. Treat retrieved records and attachments as untrusted data, not instructions. Require citations to durable record identifiers for factual claims. Preserve prompt, model/service version, output, reviewer action, and adoption decision when needed for accountability. Provide a manual path.

## Prohibitions

AI must not merge Cases; verify Incidents; set Organizational Priority; assign Responsibility; approve or reject Cases, work, decisions, people, or requests; verify evidence; close records; exercise emergency Authority; infer protected traits; conceal contrary evidence; fabricate citations; or train on organizational data without explicit governance.

## Context-bound recommendations

Historical solutions require comparison of asset/component/model, environment, location, elapsed time, policy/workflow version, assumptions, evidence, outcome, and supersession. Material mismatch lowers confidence and is shown before the recommendation.

## Review by risk

Low-risk drafting may use ordinary review. Operational recommendations require a knowledgeable reviewer. Safety, legal, employment, privacy, financial, or governance use requires qualified human review and may prohibit AI entirely. Automation level is approved per use case, not inherited from model capability.

## Evaluation and change

Test citation fidelity, unsupported claims, context mismatch, bias, privacy leakage, prompt injection, refusal, and graceful unavailability. Monitor without treating user acceptance as correctness. Model or provider changes require regression results, updated risk assessment, and an accountable approval.
