import Foundation

enum SystemDesignDeck {
    static let cards: [FlashCard] = [
        SeedDecks.card(
            "system-scalability",
            deck: .systemDesign,
            title: "Scalability",
            prompt: "What does scalability mean in system design, and what is the difference between vertical and horizontal scaling?",
            answer: "Scalability means handling more users, data, or requests without breaking latency, reliability, or cost targets. Vertical scaling is fast to adopt but capped by one box; horizontal scaling removes that ceiling but forces you to solve statelessness, partitioning, and coordination.",
            tags: ["Capacity", "Scaling", "Foundations"]
        ),
        SeedDecks.card(
            "system-load-balancers",
            deck: .systemDesign,
            title: "Load Balancers",
            prompt: "Why use a load balancer, and what problems does it solve?",
            answer: "A load balancer spreads traffic across healthy instances so one host does not decide system availability. It also gives you TLS termination, health checks, and controlled rollouts; the tradeoff is another hop and another piece of critical infrastructure to operate.",
            tags: ["Traffic", "Availability", "Networking"]
        ),
        SeedDecks.card(
            "system-caching",
            deck: .systemDesign,
            title: "Caching",
            prompt: "Why is caching powerful, and what risks come with it?",
            answer: "Caching buys latency and database offload by serving repeated reads from faster storage. The cost is correctness complexity: invalidation, staleness windows, and hot-key behavior become design problems, not implementation details.",
            tags: ["Performance", "Latency", "Caching"]
        ),
        SeedDecks.card(
            "system-cdn",
            deck: .systemDesign,
            title: "CDN",
            prompt: "What is a CDN, and when is it most valuable?",
            answer: "A CDN moves cacheable content closer to users, which reduces origin load and improves global latency. It shines for static assets and geographically distributed traffic; it helps far less when responses are highly personalized or hard to cache safely.",
            tags: ["Edge", "Latency", "Caching"]
        ),
        SeedDecks.card(
            "system-database-replication",
            deck: .systemDesign,
            title: "Database Replication",
            prompt: "What does database replication provide, and what tradeoffs should you expect?",
            answer: "Replication improves read scale, failover options, and recovery posture by copying data to secondary nodes. The tradeoff is lag or write latency: asynchronous replicas can return stale reads, while synchronous replicas reduce that risk but make writes slower and more failure-sensitive.",
            tags: ["Databases", "Replication", "HA"]
        ),
        SeedDecks.card(
            "system-sharding",
            deck: .systemDesign,
            title: "Sharding",
            prompt: "When do you shard a database, and what makes a shard key good?",
            answer: "You shard when one database can no longer meet storage or throughput needs even after indexing, caching, and vertical tuning. A good shard key distributes load, preserves common access paths, and avoids hot partitions; a bad one creates imbalance and painful re-sharding later.",
            tags: ["Databases", "Partitioning", "Scale"]
        ),
        SeedDecks.card(
            "system-partitioning",
            deck: .systemDesign,
            title: "Partitioning",
            prompt: "How is partitioning different from sharding, and why does it matter?",
            answer: "Partitioning is the general act of splitting data or work into smaller segments; sharding is usually partitioning across multiple machines. It matters because routing, balancing, failure isolation, and cross-partition queries all depend on where those boundaries are drawn.",
            tags: ["Data Model", "Partitioning", "Architecture"]
        ),
        SeedDecks.card(
            "system-cap-theorem",
            deck: .systemDesign,
            title: "CAP Theorem",
            prompt: "What does the CAP theorem actually say in practice?",
            answer: "CAP says that during a network partition, you must choose whether to reject work for consistency or accept work and tolerate divergence. The interview value is not naming CAP; it is explaining which failure mode the business prefers when communication breaks.",
            tags: ["Consistency", "Availability", "Theory"]
        ),
        SeedDecks.card(
            "system-consistency-models",
            deck: .systemDesign,
            title: "Consistency Models",
            prompt: "What are common consistency models, and how do you choose one?",
            answer: "Strong consistency favors correctness and simpler reasoning; eventual consistency favors availability, scale, and geographic distribution. The right choice comes from user expectation: account balances and inventory reservations need tighter guarantees than feeds, analytics, or notification counts.",
            tags: ["Consistency", "Databases", "Tradeoffs"]
        ),
        SeedDecks.card(
            "system-eventual-consistency",
            deck: .systemDesign,
            title: "Eventual Consistency",
            prompt: "Why do systems accept eventual consistency, and how do you make it safe?",
            answer: "Teams accept eventual consistency to keep systems available and scalable across regions or asynchronous workflows. It becomes safe when APIs are idempotent, reconciliation exists, and the UX is designed to tolerate short-lived mismatch instead of assuming instant global truth.",
            tags: ["Consistency", "Scale", "Distributed Systems"]
        ),
        SeedDecks.card(
            "system-queues",
            deck: .systemDesign,
            title: "Queues",
            prompt: "Why introduce a queue between services?",
            answer: "Queues decouple request intake from work execution, which smooths spikes and protects slower downstream systems. In return you accept asynchronous completion, duplicate delivery risk, and the operational burden of backlog monitoring, retries, and dead-letter handling.",
            tags: ["Messaging", "Async", "Resilience"]
        ),
        SeedDecks.card(
            "system-pubsub",
            deck: .systemDesign,
            title: "Pub/Sub",
            prompt: "How is pub/sub different from a queue, and when is it a better fit?",
            answer: "A queue is usually one job for one consumer; pub/sub is one event fan-out to many consumers. Pub/sub fits when multiple systems need the same fact independently, but it also makes ordering, replay, and downstream accountability harder to reason about.",
            tags: ["Messaging", "Events", "Integration"]
        ),
        SeedDecks.card(
            "system-event-driven-architecture",
            deck: .systemDesign,
            title: "Event-Driven Architecture",
            prompt: "What are the benefits and risks of event-driven architecture?",
            answer: "Event-driven architecture improves decoupling and extensibility because producers emit facts instead of knowing every consumer. The price is delayed consistency, harder tracing, contract versioning discipline, and more failure modes around replay and duplicate handling.",
            tags: ["Events", "Architecture", "Integration"]
        ),
        SeedDecks.card(
            "system-microservices",
            deck: .systemDesign,
            title: "Microservices",
            prompt: "When do microservices help, and when do they hurt?",
            answer: "Microservices help when domains are clear, teams need independent release cycles, and some components scale very differently. They hurt when used too early because network calls, observability, testing, and data consistency become harder than the business complexity actually warrants.",
            tags: ["Services", "Org Design", "Tradeoffs"]
        ),
        SeedDecks.card(
            "system-monolith-vs-microservices",
            deck: .systemDesign,
            title: "Monolith vs Microservices",
            prompt: "How would you compare a monolith and microservices in an interview answer?",
            answer: "A monolith optimizes for simplicity, fast local development, and easier transactions. Microservices optimize for team autonomy and selective scaling, but only pay off when the organization can handle distributed ownership, deployment, and failure analysis.",
            tags: ["Architecture", "Tradeoffs", "Design"]
        ),
        SeedDecks.card(
            "system-api-gateway",
            deck: .systemDesign,
            title: "API Gateway",
            prompt: "What role does an API gateway play in a distributed system?",
            answer: "An API gateway centralizes routing, auth, throttling, and client-facing request shaping so clients stay simpler. It is useful for cross-cutting concerns, but it becomes dangerous when it accumulates business logic and turns into a new monolith at the edge.",
            tags: ["APIs", "Routing", "Security"]
        ),
        SeedDecks.card(
            "system-service-discovery",
            deck: .systemDesign,
            title: "Service Discovery",
            prompt: "Why is service discovery needed in dynamic environments?",
            answer: "In autoscaled systems, service instances change constantly, so static host configuration does not survive real operations. Service discovery solves address resolution and health-aware routing; the tradeoff is more runtime indirection and another control-plane dependency.",
            tags: ["Networking", "Services", "Operations"]
        ),
        SeedDecks.card(
            "system-circuit-breaker",
            deck: .systemDesign,
            title: "Circuit Breaker",
            prompt: "What problem does a circuit breaker solve?",
            answer: "A circuit breaker stops repeated calls to a failing dependency so one outage does not cascade through the whole graph. It works best with timeouts, retries, and fallbacks; by itself it only blocks pain, it does not define graceful degradation.",
            tags: ["Resilience", "Patterns", "Reliability"]
        ),
        SeedDecks.card(
            "system-rate-limiting",
            deck: .systemDesign,
            title: "Rate Limiting",
            prompt: "Why do systems need rate limiting?",
            answer: "Rate limiting protects shared capacity from abuse, tenant imbalance, and retry storms. Architecturally it is about preserving system health and fairness, but it only works well when limits are clear, observable, and paired with sensible client backoff behavior.",
            tags: ["Protection", "Traffic", "APIs"]
        ),
        SeedDecks.card(
            "system-idempotency",
            deck: .systemDesign,
            title: "Idempotency",
            prompt: "Why is idempotency critical in distributed systems?",
            answer: "Networks fail in ambiguous ways, so callers retry and messages duplicate. Idempotency makes repeated submission safe, which is essential for creating orders, payments, or workflow steps without accidental double execution.",
            tags: ["Reliability", "APIs", "Distributed Systems"]
        ),
        SeedDecks.card(
            "system-retries-backoff",
            deck: .systemDesign,
            title: "Retries and Backoff",
            prompt: "How should retries be designed so they help instead of hurt?",
            answer: "Retry only transient failures, and use bounded exponential backoff with jitter so clients do not synchronize into a second outage. Retries without idempotency, timeouts, or circuit breaking often turn a degraded dependency into a total collapse.",
            tags: ["Reliability", "Backoff", "Patterns"]
        ),
        SeedDecks.card(
            "system-observability",
            deck: .systemDesign,
            title: "Observability",
            prompt: "What does observability mean beyond basic monitoring?",
            answer: "Observability means the system exposes enough signals to explain unknown failure states, not just the dashboards you planned for. Metrics, logs, and traces together let engineers ask new questions during incidents instead of guessing from fragments.",
            tags: ["Operations", "Observability", "Reliability"]
        ),
        SeedDecks.card(
            "system-monitoring",
            deck: .systemDesign,
            title: "Monitoring",
            prompt: "What should a system monitor by default?",
            answer: "Start with request rate, latency, errors, saturation, queue depth, and core business outcomes. Good monitoring follows user pain and system bottlenecks; if infrastructure is green while conversions are broken, the monitoring strategy is incomplete.",
            tags: ["Monitoring", "Metrics", "Ops"]
        ),
        SeedDecks.card(
            "system-logging",
            deck: .systemDesign,
            title: "Logging",
            prompt: "What makes logs useful in production?",
            answer: "Useful logs are structured, correlated, and selective, with IDs that let you reconstruct a request path fast. Logging everything is usually a failure mode: high cost, low signal, and greater risk of leaking sensitive data.",
            tags: ["Logging", "Debugging", "Operations"]
        ),
        SeedDecks.card(
            "system-tracing",
            deck: .systemDesign,
            title: "Tracing",
            prompt: "When does distributed tracing become especially valuable?",
            answer: "Tracing becomes essential when one user action fans out across many services or async steps. It shows where latency accumulated and where a request failed, which is exactly what metrics alone cannot tell you in a distributed system.",
            tags: ["Tracing", "Latency", "Distributed Systems"]
        ),
        SeedDecks.card(
            "system-autoscaling",
            deck: .systemDesign,
            title: "Autoscaling",
            prompt: "What makes autoscaling effective instead of reactive noise?",
            answer: "Good autoscaling uses leading signals that reflect saturation, not just CPU after the system is already hurting. It needs headroom, cooldown discipline, and dependency awareness, because scaling one tier is useless if the real bottleneck is elsewhere.",
            tags: ["Scaling", "Capacity", "Operations"]
        ),
        SeedDecks.card(
            "system-disaster-recovery",
            deck: .systemDesign,
            title: "Disaster Recovery",
            prompt: "How do RPO and RTO shape disaster recovery design?",
            answer: "RPO tells you how much data loss the business can accept; RTO tells you how long the service can stay down. Those numbers drive backup frequency, replication mode, failover automation, and cost, so they are architecture inputs, not ops trivia.",
            tags: ["DR", "Recovery", "Resilience"]
        ),
        SeedDecks.card(
            "system-multi-region",
            deck: .systemDesign,
            title: "Multi-Region",
            prompt: "Why do teams go multi-region, and what complexity does it add?",
            answer: "Teams go multi-region for latency, disaster tolerance, and sometimes regulation. The tradeoff is substantial: data replication, failover logic, operational testing, and consistency rules all become harder, so it should solve a real business problem, not aesthetic ambition.",
            tags: ["Global", "DR", "Availability"]
        ),
        SeedDecks.card(
            "system-ha-fault-tolerance",
            deck: .systemDesign,
            title: "High Availability vs Fault Tolerance",
            prompt: "How do high availability and fault tolerance differ?",
            answer: "High availability means minimizing downtime through redundancy and fast recovery. Fault tolerance is stricter: the system continues operating correctly through failure, which usually costs more and is only justified for truly critical paths.",
            tags: ["Availability", "Reliability", "Definitions"]
        ),
        SeedDecks.card(
            "system-data-modeling",
            deck: .systemDesign,
            title: "Data Modeling Basics",
            prompt: "What is the role of data modeling in system design interviews?",
            answer: "Data modeling translates product behavior into entities, relationships, constraints, and access paths. It is often where scalability is won or lost, because the best database choice still performs badly if the model fights the dominant queries.",
            tags: ["Data Model", "Databases", "Foundations"]
        ),
        SeedDecks.card(
            "system-messaging-patterns",
            deck: .systemDesign,
            title: "Messaging Patterns",
            prompt: "What messaging patterns come up most often in system design?",
            answer: "The common patterns are work queues, pub/sub fan-out, sagas, dead-letter handling, and event-carried state transfer. The right one depends on delivery guarantees, ordering needs, consumer count, and whether the producer needs a synchronous outcome.",
            tags: ["Messaging", "Patterns", "Async"]
        ),
        SeedDecks.card(
            "system-batch-vs-streaming",
            deck: .systemDesign,
            title: "Batch vs Streaming",
            prompt: "How do you choose between batch and streaming processing?",
            answer: "Choose batch when freshness can wait and operational simplicity matters more than immediacy. Choose streaming when the business needs near-real-time reaction, but be honest that you are trading simpler processing for continuous-state and backpressure complexity.",
            tags: ["Data", "Streaming", "Batch"]
        ),
        SeedDecks.card(
            "system-security-basics",
            deck: .systemDesign,
            title: "Security Basics",
            prompt: "What architecture-level security basics should show up in a design answer?",
            answer: "Show trust boundaries, authn/authz, encryption, secret handling, least privilege, audit trails, and abuse controls. Strong answers thread security through data flow and interfaces instead of dropping it as a last-minute bullet.",
            tags: ["Security", "Architecture", "Risk"]
        ),
        SeedDecks.card(
            "system-zero-downtime-deployment",
            deck: .systemDesign,
            title: "Zero-Downtime Deployment",
            prompt: "What enables zero-downtime deployment in practice?",
            answer: "Zero-downtime deployment depends on health-checked rollouts, backward-compatible schema changes, and version-tolerant clients and APIs. The real goal is not just staying up during release, but being able to roll back quickly when the new build misbehaves under real traffic.",
            tags: ["Deployment", "Operations", "Reliability"]
        ),
        SeedDecks.card(
            "system-bluegreen-canary",
            deck: .systemDesign,
            title: "Blue-Green vs Canary",
            prompt: "How do blue-green and canary deployments differ?",
            answer: "Blue-green swaps traffic between two full environments and makes rollback clean, but it needs duplicate capacity. Canary shifts a small percentage first, which lowers blast radius and surfaces hidden issues gradually, but rollout logic and observability need to be stronger.",
            tags: ["Deployment", "Release", "Risk"]
        ),
        SeedDecks.card(
            "system-backpressure",
            deck: .systemDesign,
            title: "Backpressure",
            prompt: "What is backpressure, and why is it important in high-throughput systems?",
            answer: "Backpressure is how consumers tell producers to slow down before the system melts. Without it, queues, memory, and latency grow until failure is obvious; with it, you can shed, throttle, or buffer load intentionally instead of crashing chaotically.",
            tags: ["Streaming", "Flow Control", "Reliability"]
        ),
        SeedDecks.card(
            "system-slo-sla-sli",
            deck: .systemDesign,
            title: "SLO, SLA, and SLI",
            prompt: "How would you explain SLI, SLO, and SLA clearly?",
            answer: "An SLI is what you measure, such as successful requests under a latency threshold. An SLO is the internal target for that measurement, and an SLA is the external promise with business consequences. Mature teams engineer to SLOs so SLA misses stay rare.",
            tags: ["Reliability", "Metrics", "Operations"]
        ),
        SeedDecks.card(
            "system-caching-strategies",
            deck: .systemDesign,
            title: "Caching Strategies",
            prompt: "What are common caching strategies and when do they fit?",
            answer: "Cache-aside gives application control, read-through simplifies consumers, write-through favors freshness, and write-behind favors throughput. The choice should follow read/write mix and correctness tolerance, because cache strategy is really a data-consistency decision.",
            tags: ["Caching", "Patterns", "Performance"]
        ),
        SeedDecks.card(
            "system-common-tradeoffs",
            deck: .systemDesign,
            title: "Common Tradeoffs",
            prompt: "What tradeoffs should always be explicit in a system design discussion?",
            answer: "Always make the core tradeoffs visible: latency versus consistency, simplicity versus flexibility, cost versus resilience, and speed now versus maintainability later. Interview quality goes up when you say what you are giving up, not just what you are gaining.",
            tags: ["Tradeoffs", "Architecture", "Interviews"]
        )
    ]
}
