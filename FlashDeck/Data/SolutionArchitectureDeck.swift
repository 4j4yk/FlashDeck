import Foundation

enum SolutionArchitectureDeck {
    static let cards: [FlashCard] = [
        SeedDecks.card(
            "solution-requirements-gathering",
            deck: .solutionArchitecture,
            title: "Requirements Gathering",
            prompt: "What does strong requirements gathering look like for a solution architect?",
            answer: "Strong requirements gathering separates outcomes, constraints, assumptions, and edge cases before teams commit to a solution shape. The architect's job is to turn vague ambition into buildable decisions, especially around scope, quality targets, and hidden dependencies.",
            tags: ["Discovery", "Requirements", "Foundations"]
        ),
        SeedDecks.card(
            "solution-stakeholder-management",
            deck: .solutionArchitecture,
            title: "Stakeholder Management",
            prompt: "Why is stakeholder management a technical architecture skill?",
            answer: "Architecture fails from misalignment more often than from missing diagrams. Stakeholder management is how you surface competing goals early, get explicit decision owners, and stop late surprises from rewriting the delivery plan under pressure.",
            tags: ["Leadership", "Communication", "Alignment"]
        ),
        SeedDecks.card(
            "solution-tradeoff-analysis",
            deck: .solutionArchitecture,
            title: "Tradeoff Analysis",
            prompt: "How should an architect present tradeoff analysis?",
            answer: "Present realistic options against agreed criteria such as time to market, risk, cost, security, and operating model fit. Good tradeoff analysis does not argue for a favorite first; it makes the consequences of each option clear enough for the business to choose deliberately.",
            tags: ["Decision Making", "Tradeoffs", "Architecture"]
        ),
        SeedDecks.card(
            "solution-risk-identification",
            deck: .solutionArchitecture,
            title: "Risk Identification",
            prompt: "What kinds of risks should a solution architect identify early?",
            answer: "Early risks usually sit in dependencies, migration complexity, unclear ownership, skill gaps, compliance, and optimistic assumptions about scale or change. Good architects convert those into mitigation plans, checkpoints, and explicit decision records instead of vague caution statements.",
            tags: ["Risk", "Planning", "Governance"]
        ),
        SeedDecks.card(
            "solution-nfrs",
            deck: .solutionArchitecture,
            title: "Non-Functional Requirements",
            prompt: "Why do non-functional requirements drive architecture more than many teams expect?",
            answer: "Two solutions can satisfy the same features and still be architecturally opposite once latency, resilience, recovery, auditability, and data residency are added. NFRs are often the real reason a platform, topology, or integration style is right or wrong.",
            tags: ["NFRs", "Architecture", "Quality"]
        ),
        SeedDecks.card(
            "solution-integration-patterns",
            deck: .solutionArchitecture,
            title: "Integration Patterns",
            prompt: "How do you choose among synchronous, asynchronous, and event-driven integration patterns?",
            answer: "Use synchronous integration when a caller truly needs an immediate answer and can tolerate dependency coupling. Use async or event-driven patterns when resilience, throughput smoothing, or many downstream consumers matter more than instant completion.",
            tags: ["Integration", "Patterns", "Systems"]
        ),
        SeedDecks.card(
            "solution-migration-strategy",
            deck: .solutionArchitecture,
            title: "Migration Strategy",
            prompt: "What makes a migration strategy credible?",
            answer: "A credible migration strategy names the transition steps, data movement approach, rollback path, validation checkpoints, and business continuity rules. It proves you have designed the journey, not just the target-state slide.",
            tags: ["Migration", "Planning", "Transformation"]
        ),
        SeedDecks.card(
            "solution-buy-vs-build",
            deck: .solutionArchitecture,
            title: "Buy vs Build",
            prompt: "How should teams think about buy versus build decisions?",
            answer: "Buy when the capability is commodity and the real differentiator is speed or operating simplicity. Build when the capability is strategic, deeply workflow-specific, or likely to become a constraint if owned by a vendor.",
            tags: ["Strategy", "Platform", "Decision Making"]
        ),
        SeedDecks.card(
            "solution-platform-selection",
            deck: .solutionArchitecture,
            title: "Platform Selection",
            prompt: "What criteria matter in platform selection beyond feature checklists?",
            answer: "Platform selection should test operating model fit, security posture, ecosystem maturity, skills, cost behavior, and exit risk, not just feature breadth. The wrong platform often fails because the team cannot run it well, not because it lacked a checkbox.",
            tags: ["Platforms", "Evaluation", "Architecture"]
        ),
        SeedDecks.card(
            "solution-design-reviews",
            deck: .solutionArchitecture,
            title: "Design Reviews",
            prompt: "What makes a design review effective?",
            answer: "An effective design review pressures assumptions, risks, integration boundaries, and failure modes rather than polishing diagrams. It should improve decisions and expose weak thinking early, not function as a ceremonial approval gate.",
            tags: ["Reviews", "Quality", "Governance"]
        ),
        SeedDecks.card(
            "solution-adrs",
            deck: .solutionArchitecture,
            title: "Architecture Decision Records",
            prompt: "Why use ADRs, and what should they capture?",
            answer: "ADRs capture the problem context, options considered, decision taken, and consequences accepted. Their real value is preserving intent so future teams can evolve the solution without re-litigating old decisions from memory.",
            tags: ["Documentation", "Decisions", "Governance"]
        ),
        SeedDecks.card(
            "solution-technical-debt",
            deck: .solutionArchitecture,
            title: "Technical Debt",
            prompt: "How should a solution architect talk about technical debt without being vague?",
            answer: "Technical debt should be framed as future delivery drag, resilience risk, or operating cost created by today's shortcut. If it cannot be tied to business impact or delivery friction, it is usually not an architecture-level argument yet.",
            tags: ["Debt", "Maintainability", "Delivery"]
        ),
        SeedDecks.card(
            "solution-roadmap-alignment",
            deck: .solutionArchitecture,
            title: "Roadmap Alignment",
            prompt: "Why must architecture align to the product roadmap?",
            answer: "Architecture should support the next real business steps, not an imagined perfect future. Roadmap alignment keeps teams from overbuilding and helps sequence platform investment where it unlocks known product or operational value.",
            tags: ["Strategy", "Roadmap", "Planning"]
        ),
        SeedDecks.card(
            "solution-governance",
            deck: .solutionArchitecture,
            title: "Governance",
            prompt: "What is healthy architecture governance?",
            answer: "Healthy governance gives teams clear guardrails for security, data handling, resilience, and integration without forcing every decision through a central bottleneck. The best governance removes ambiguity and speeds delivery by standardizing the non-negotiables.",
            tags: ["Governance", "Standards", "Architecture"]
        ),
        SeedDecks.card(
            "solution-cost-optimization",
            deck: .solutionArchitecture,
            title: "Cost Optimization",
            prompt: "How should architects think about cost optimization?",
            answer: "Cost optimization is not simply lower spend; it is the cheapest design that still meets the right reliability, security, and delivery needs. Good architects challenge idle capacity, poor service fit, and overly bespoke builds before they become structural waste.",
            tags: ["Cost", "Optimization", "Cloud"]
        ),
        SeedDecks.card(
            "solution-resiliency-planning",
            deck: .solutionArchitecture,
            title: "Resiliency Planning",
            prompt: "What belongs in resiliency planning for a solution?",
            answer: "Resiliency planning covers dependency failure, degraded modes, recovery expectations, capacity headroom, and who operates the solution under stress. It is where availability targets become concrete engineering and support decisions.",
            tags: ["Resilience", "Planning", "Reliability"]
        ),
        SeedDecks.card(
            "solution-security-by-design",
            deck: .solutionArchitecture,
            title: "Security by Design",
            prompt: "What does security by design mean at the solution level?",
            answer: "Security by design means identity, trust boundaries, privilege scope, encryption, and audit needs shape the architecture from the first draft. It avoids the common failure mode where teams try to bolt controls onto interfaces and data paths already fixed in place.",
            tags: ["Security", "Risk", "Architecture"]
        ),
        SeedDecks.card(
            "solution-compliance-awareness",
            deck: .solutionArchitecture,
            title: "Compliance Awareness",
            prompt: "Why does compliance awareness matter even if architects are not lawyers?",
            answer: "Compliance changes storage, retention, access, logging, vendor choice, and sometimes geography. Architects do not have to interpret every regulation, but they do need to recognize when the design crosses into regulated territory and bring the right people in early.",
            tags: ["Compliance", "Risk", "Data"]
        ),
        SeedDecks.card(
            "solution-data-flow-thinking",
            deck: .solutionArchitecture,
            title: "Data Flow Thinking",
            prompt: "Why is explicit data flow thinking so important?",
            answer: "Data flow thinking exposes where data originates, transforms, persists, crosses trust boundaries, and is consumed. That view usually reveals the real architecture questions around latency, ownership, privacy, and integration coupling.",
            tags: ["Data", "Architecture", "Clarity"]
        ),
        SeedDecks.card(
            "solution-dependency-mapping",
            deck: .solutionArchitecture,
            title: "Dependency Mapping",
            prompt: "How does dependency mapping improve delivery outcomes?",
            answer: "Dependency mapping makes hidden coordination visible across teams, systems, vendors, and data contracts. That lets you plan sequencing realistically instead of discovering late that a 'small' change depends on five other roadmaps and two external approvals.",
            tags: ["Dependencies", "Planning", "Delivery"]
        ),
        SeedDecks.card(
            "solution-change-management",
            deck: .solutionArchitecture,
            title: "Change Management",
            prompt: "Why should solution architects care about change management?",
            answer: "A technically correct solution can still fail if the organization cannot absorb the process, training, or operating changes it requires. Change management is part of architecture because adoption risk is often larger than implementation risk.",
            tags: ["Adoption", "Transformation", "Delivery"]
        ),
        SeedDecks.card(
            "solution-cross-team-communication",
            deck: .solutionArchitecture,
            title: "Cross-Team Communication",
            prompt: "What does strong cross-team communication look like in architecture work?",
            answer: "Strong communication creates shared language, explicit interfaces, decision cadence, and visible ownership across product, engineering, security, and operations. It reduces rework because teams can act on the same architecture, not five local interpretations of it.",
            tags: ["Communication", "Leadership", "Alignment"]
        ),
        SeedDecks.card(
            "solution-solution-framing",
            deck: .solutionArchitecture,
            title: "Solution Framing",
            prompt: "What is solution framing, and why is it useful early?",
            answer: "Solution framing defines the problem, outcomes, scope edges, hard constraints, and plausible directions before detailed design begins. It stops discovery from collapsing into premature implementation debates with no shared definition of success.",
            tags: ["Discovery", "Framing", "Architecture"]
        ),
        SeedDecks.card(
            "solution-discovery-workshops",
            deck: .solutionArchitecture,
            title: "Discovery Workshops",
            prompt: "What should a good architecture discovery workshop produce?",
            answer: "A good workshop should produce clearer goals, constraints, context, decision owners, and a ranked list of open questions. If the meeting ends with only broad agreement and no sharper next steps, it was discussion, not discovery.",
            tags: ["Discovery", "Workshops", "Facilitation"]
        ),
        SeedDecks.card(
            "solution-current-future-state",
            deck: .solutionArchitecture,
            title: "Current State vs Future State",
            prompt: "Why compare current state and future state explicitly?",
            answer: "Comparing current and future state exposes the actual delta in capability, process, data, and operating model. That delta is where migration effort, risk, and budget live, which is why target-state diagrams alone are rarely useful enough.",
            tags: ["Transformation", "Planning", "State Modeling"]
        ),
        SeedDecks.card(
            "solution-reference-architecture",
            deck: .solutionArchitecture,
            title: "Reference Architecture",
            prompt: "What is a reference architecture good for?",
            answer: "A reference architecture gives teams a repeatable starting point for common patterns, controls, and integration choices. It adds value when it accelerates good defaults; it becomes harmful when treated as a rigid template that ignores solution context.",
            tags: ["Standards", "Reuse", "Governance"]
        ),
        SeedDecks.card(
            "solution-domain-boundaries",
            deck: .solutionArchitecture,
            title: "Domain Boundaries",
            prompt: "Why do domain boundaries matter in solution architecture?",
            answer: "Clear domain boundaries define who owns data, logic, and interfaces, which reduces coordination drag and duplicated behavior. Weak boundaries show up later as tangled APIs, contested ownership, and platform work that never quite stabilizes.",
            tags: ["Domains", "Ownership", "Design"]
        ),
        SeedDecks.card(
            "solution-api-first",
            deck: .solutionArchitecture,
            title: "API-First Thinking",
            prompt: "What does API-first thinking change in a solution?",
            answer: "API-first thinking forces teams to agree on contracts, consumer needs, and versioning before implementation specifics take over. It is especially useful in multi-team environments where interface clarity matters more than any one team's internal code structure.",
            tags: ["API", "Integration", "Contracts"]
        ),
        SeedDecks.card(
            "solution-documentation-discipline",
            deck: .solutionArchitecture,
            title: "Documentation Discipline",
            prompt: "What documentation actually matters for solution delivery?",
            answer: "The useful set is decision context, core diagrams, interfaces, operational assumptions, risks, and unresolved questions. Documentation earns its keep when another team can build, run, and evolve the solution without relying on tribal memory.",
            tags: ["Documentation", "Delivery", "Clarity"]
        ),
        SeedDecks.card(
            "solution-operational-readiness",
            deck: .solutionArchitecture,
            title: "Operational Readiness",
            prompt: "What does operational readiness include before go-live?",
            answer: "Operational readiness means monitoring, alerting, backup validation, access control, incident paths, ownership, and runbooks are in place before launch. If nobody can support the system at 2 a.m., it is not production-ready yet.",
            tags: ["Operations", "Go Live", "Reliability"]
        ),
        SeedDecks.card(
            "solution-handoff-to-engineering",
            deck: .solutionArchitecture,
            title: "Handoff to Engineering",
            prompt: "What makes an architecture handoff to engineering effective?",
            answer: "A good handoff preserves intent, constraints, interfaces, and quality targets without pretending all unknowns are resolved. Engineering should inherit a clear problem space and decision baseline, not a vague vision or an unworkably rigid blueprint.",
            tags: ["Engineering", "Delivery", "Collaboration"]
        ),
        SeedDecks.card(
            "solution-performance-thinking",
            deck: .solutionArchitecture,
            title: "Performance Thinking",
            prompt: "How should architects think about performance before the system exists?",
            answer: "Performance thinking starts with user journeys, latency budgets, throughput expectations, and likely hot paths. The goal is not premature tuning; it is avoiding architectural choices that make good performance impossible later.",
            tags: ["Performance", "Capacity", "Architecture"]
        ),
        SeedDecks.card(
            "solution-architecture-communication",
            deck: .solutionArchitecture,
            title: "Architecture Communication",
            prompt: "Why is architecture communication a core skill, not a soft extra?",
            answer: "Architecture communication turns complexity into decisions that different audiences can actually act on. Leaders need risk and value, engineers need constraints and interfaces, and operators need ownership and failure expectations; one message does not serve all three.",
            tags: ["Communication", "Leadership", "Influence"]
        ),
        SeedDecks.card(
            "solution-business-capability-mapping",
            deck: .solutionArchitecture,
            title: "Business Capability Mapping",
            prompt: "How does business capability mapping help an architect?",
            answer: "Capability mapping links technology decisions to business abilities rather than individual apps or teams. It is useful when you need to find duplication, platform candidates, or where architecture effort will unlock the most organizational change.",
            tags: ["Business", "Capabilities", "Planning"]
        ),
        SeedDecks.card(
            "solution-vendor-evaluation",
            deck: .solutionArchitecture,
            title: "Vendor Evaluation",
            prompt: "What should a vendor evaluation include beyond price and features?",
            answer: "A serious vendor evaluation includes security, integration quality, roadmap fit, data portability, support model, and commercial flexibility. Cheap can become expensive fast if the vendor adds lock-in, operational burden, or weak exit options.",
            tags: ["Vendors", "Evaluation", "Risk"]
        ),
        SeedDecks.card(
            "solution-failure-mode-thinking",
            deck: .solutionArchitecture,
            title: "Failure Mode Thinking",
            prompt: "Why is failure mode thinking valuable in architecture work?",
            answer: "Failure mode thinking asks what happens when dependencies are slow, unavailable, inconsistent, or misconfigured. That exposes missing defaults, unsafe coupling, and operational gaps long before production does it for you.",
            tags: ["Resilience", "Risk", "Design Quality"]
        )
    ]
}
