# Evidence Model

Version: 2.0  
Status: Architecture Baseline

## Purpose

The Evidence model preserves material that supports or challenges operational claims while keeping provenance, uncertainty, privacy, and chronology visible.

## Evidence Item

An Evidence Item has durable identity; media or document reference; creator/source; custodian; capture method; event/capture, record, and upload times; location and device metadata when available; integrity digest; access classification; consent/legal basis; retention class; and links to claims or records. A narrative observation may be evidence but is not automatically verified fact.

## Evidence Package

A package groups items for a defined question such as diagnosis or verification. It records selection criteria, omissions, compiler, time, and integrity manifest. Packaging never changes source items.

## Provenance and integrity

Original bytes are immutable. Derived images, annotations, transcripts, redactions, and compression are new renditions linked to the original with transformation details. Corrections add metadata assertions. Chain-of-custody events record possession or control changes.

## Evidence states

Captured, Uploaded, IntegrityChecked, Reviewed, Challenged, Restricted, and Disposed describe independent lifecycle aspects rather than a single truth score. Human reviewers record relevance, reliability, limitations, and which claim is supported or challenged.

## Delayed or impossible capture

Safety comes first. If danger, battery failure, connectivity, privacy, or physical limits prevent capture, the actor records the reason and reconstructs an observation when feasible. The system distinguishes missing evidence from negative evidence and never blocks stabilization.

## Access and removal requests

Sensitive evidence uses purpose-based access, redacted views, and audited disclosure. A request to remove embarrassing material is evaluated under law and retention policy; embarrassment alone does not authorize deletion. Lawful disposal creates a tombstone containing authority, scope, method, and time without retaining prohibited content.

## Standards

Minimum capture and verification requirements by risk are defined in [27_evidence_standards.md](27_evidence_standards.md). Evidence influences but does not itself make decisions; see [09_decision_model.md](09_decision_model.md).
