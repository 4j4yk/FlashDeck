# Security Policy

## Supported Versions

Only the latest GitHub release should be treated as supported for security fixes.

## Reporting A Vulnerability

Preferred path:

1. Use GitHub private vulnerability reporting for the published repository.
2. Do not post exploit details, secrets, or proof-of-concept payloads in a public issue.
3. Public GitHub Issues are for non-sensitive bugs only.

## Repository Setting Recommendation

Public releases should enable GitHub private vulnerability reporting when the repository settings allow it.

## Response Goals

- initial acknowledgment within 7 days
- fix or mitigation plan when reproducible
- coordinated public disclosure after a fix is ready

## Scope Notes

This project is local-first and does not ship a backend in the default build.

Likely reportable issues include:

- unsafe import handling
- local file corruption or privilege issues
- release artifact integrity problems
- unexpected network calls in a release
