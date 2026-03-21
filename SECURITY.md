# Security Policy

## Supported Versions

Only the latest GitHub release should be treated as supported for security fixes.

## Reporting A Vulnerability

Preferred path:

1. Use GitHub private vulnerability reporting for the published repository.
2. Do not post exploit details, secrets, or proof-of-concept payloads in a public issue.
3. Public GitHub Issues are for non-sensitive bugs only.

## Release Requirement

Public releases should not be published until GitHub private vulnerability reporting is enabled for the repository.

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
