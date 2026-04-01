import Foundation

enum AWSDeck {
    static let cards: [FlashCard] = [
        // Compute
        SeedDecks.card(
            "aws-ec2",
            deck: .awsServices,
            title: "Amazon EC2",
            prompt: "What is EC2, and when is it the right compute choice?",
            answer: "EC2 is raw VM compute with full OS and network control. Use it for custom runtimes, agents, stateful services, or software that expects server access; compare with Lambda or Fargate when the real problem is undifferentiated server management.",
            tags: ["Compute", "VMs", "Core AWS"]
        ),
        SeedDecks.card(
            "aws-lambda",
            deck: .awsServices,
            title: "AWS Lambda",
            prompt: "What is Lambda best for, and where does it become a poor fit?",
            answer: "Lambda is event-driven serverless compute for short, stateless work with bursty demand. Use it for APIs, automations, and async handlers; avoid it when you need long-lived state, predictable warm performance, or host-level control.",
            tags: ["Compute", "Serverless", "Events"]
        ),
        SeedDecks.card(
            "aws-ecs",
            deck: .awsServices,
            title: "Amazon ECS",
            prompt: "What is ECS, and when would you choose it over other container options?",
            answer: "ECS is AWS-native container orchestration with less operational overhead than Kubernetes. Choose it for containerized services when portability is less important than simpler operations and tight AWS integration; compare with EKS when Kubernetes ecosystem standards matter.",
            tags: ["Compute", "Containers", "Orchestration"]
        ),
        SeedDecks.card(
            "aws-eks",
            deck: .awsServices,
            title: "Amazon EKS",
            prompt: "When is EKS the right answer?",
            answer: "EKS is managed Kubernetes for teams that need Kubernetes APIs, tooling, and patterns at scale. Use it when platform consistency or portability matters; compare with ECS or App Runner when you want containers without Kubernetes-level operational weight.",
            tags: ["Compute", "Kubernetes", "Containers"]
        ),
        SeedDecks.card(
            "aws-fargate",
            deck: .awsServices,
            title: "AWS Fargate",
            prompt: "What problem does Fargate solve for container workloads?",
            answer: "Fargate runs containers without you managing cluster nodes. It is a good fit when you want container packaging but do not want EC2 fleet operations; compare with EC2-backed ECS/EKS when you need tighter cost control or deeper host tuning.",
            tags: ["Compute", "Containers", "Serverless"]
        ),
        SeedDecks.card(
            "aws-elastic-beanstalk",
            deck: .awsServices,
            title: "AWS Elastic Beanstalk",
            prompt: "What is Elastic Beanstalk, and when is it useful?",
            answer: "Elastic Beanstalk is a managed deployment layer for common web app stacks. Use it for straightforward app hosting when speed beats customization; compare with ECS, App Runner, or IaC-driven stacks once the team needs cleaner control of networking, scaling, and release patterns.",
            tags: ["Compute", "PaaS", "Web Apps"]
        ),
        SeedDecks.card(
            "aws-batch",
            deck: .awsServices,
            title: "AWS Batch",
            prompt: "When is AWS Batch more appropriate than a generic container platform?",
            answer: "AWS Batch is for queued, offline compute jobs where scheduling, retries, and elastic capacity matter more than request latency. Use it for simulations, rendering, or large ETL steps; compare with ECS/EKS when the workload is an always-on service instead of a job queue.",
            tags: ["Compute", "Batch", "Scheduling"]
        ),
        SeedDecks.card(
            "aws-lightsail",
            deck: .awsServices,
            title: "Amazon Lightsail",
            prompt: "What is Lightsail best suited for?",
            answer: "Lightsail is simplified VPS-style hosting with predictable bundled pricing. It fits prototypes, small websites, and simple workloads; compare with full AWS services when you need fine-grained networking, managed integrations, or serious scaling patterns.",
            tags: ["Compute", "Simple Hosting", "SMB"]
        ),
        SeedDecks.card(
            "aws-app-runner",
            deck: .awsServices,
            title: "AWS App Runner",
            prompt: "What is App Runner, and how does it fit between Lambda and container orchestration?",
            answer: "App Runner is managed HTTP app hosting from code or containers with very little platform setup. Use it when you want a web service in production quickly; compare with Lambda for event-style functions and ECS/EKS when platform flexibility matters more than simplicity.",
            tags: ["Compute", "Containers", "Managed Runtime"]
        ),

        // Storage
        SeedDecks.card(
            "aws-s3",
            deck: .awsServices,
            title: "Amazon S3",
            prompt: "What is S3, and why is it so central in AWS architectures?",
            answer: "S3 is durable object storage for files, backups, logs, static assets, and data lakes. Use it when you store blobs and large datasets; compare with EBS for block semantics or EFS/FSx when applications need a mounted filesystem.",
            tags: ["Storage", "Object Storage", "Core AWS"]
        ),
        SeedDecks.card(
            "aws-ebs",
            deck: .awsServices,
            title: "Amazon EBS",
            prompt: "What is EBS, and when is it the right storage choice?",
            answer: "EBS is persistent block storage attached to EC2. Use it for boot disks and database-style workloads that want disk semantics; compare with EFS when multiple instances need shared access, and with S3 when the data is really object storage.",
            tags: ["Storage", "Block Storage", "EC2"]
        ),
        SeedDecks.card(
            "aws-efs",
            deck: .awsServices,
            title: "Amazon EFS",
            prompt: "Why choose EFS instead of EBS or S3?",
            answer: "EFS is a managed shared filesystem for Linux workloads across many instances or containers. Use it when multiple compute nodes need the same file tree; compare with EBS for single-node block performance and S3 when filesystem semantics are unnecessary.",
            tags: ["Storage", "Filesystem", "Shared"]
        ),
        SeedDecks.card(
            "aws-fsx",
            deck: .awsServices,
            title: "Amazon FSx",
            prompt: "What is FSx for, and how does it differ from EFS?",
            answer: "FSx is managed filesystem storage optimized for specific workloads such as Windows, Lustre, ONTAP, or OpenZFS. Use it when workload semantics matter; compare with EFS when you just need general shared Linux storage rather than a specialized filesystem.",
            tags: ["Storage", "Filesystem", "Specialized"]
        ),

        // Databases
        SeedDecks.card(
            "aws-rds",
            deck: .awsServices,
            title: "Amazon RDS",
            prompt: "What does RDS provide, and when is it a good fit?",
            answer: "RDS is managed relational database hosting for standard engines such as PostgreSQL and MySQL. Use it for transactional apps that need SQL and managed backups; compare with DynamoDB for scale-out NoSQL and with Aurora when higher performance or failover behavior matters.",
            tags: ["Databases", "Relational", "Managed"]
        ),
        SeedDecks.card(
            "aws-aurora",
            deck: .awsServices,
            title: "Amazon Aurora",
            prompt: "When should Aurora be considered instead of standard RDS engines?",
            answer: "Aurora is AWS's cloud-optimized relational database for MySQL/PostgreSQL-compatible workloads. Use it when you want managed relational scale and stronger HA characteristics than a typical RDS setup; compare with plain RDS when you do not need Aurora's extra performance or AWS-specific features.",
            tags: ["Databases", "Relational", "Performance"]
        ),
        SeedDecks.card(
            "aws-dynamodb",
            deck: .awsServices,
            title: "Amazon DynamoDB",
            prompt: "What kinds of problems is DynamoDB built for?",
            answer: "DynamoDB is low-latency managed NoSQL built for high scale and access-pattern-driven design. Use it for key-based workloads such as carts, sessions, or profile state; compare with RDS when joins, rich ad hoc queries, and strong relational modeling matter more.",
            tags: ["Databases", "NoSQL", "Scale"]
        ),
        SeedDecks.card(
            "aws-elasticache",
            deck: .awsServices,
            title: "Amazon ElastiCache",
            prompt: "When do you bring in ElastiCache?",
            answer: "ElastiCache adds in-memory speed for hot data, sessions, counters, or transient coordination patterns. Use it when the database is too slow or expensive for repeated reads; compare with DynamoDB DAX or application-level caching depending on the access pattern and consistency needs.",
            tags: ["Databases", "Caching", "Performance"]
        ),
        SeedDecks.card(
            "aws-redshift",
            deck: .awsServices,
            title: "Amazon Redshift",
            prompt: "What is Redshift for, and when is it the better database answer?",
            answer: "Redshift is a data warehouse for large analytical SQL workloads. Use it for BI and reporting over large datasets; compare with RDS for OLTP and Athena when you want SQL on S3 without standing up a warehouse.",
            tags: ["Databases", "Analytics", "Warehouse"]
        ),
        SeedDecks.card(
            "aws-neptune",
            deck: .awsServices,
            title: "Amazon Neptune",
            prompt: "What problem is Neptune built to solve?",
            answer: "Neptune is a graph database for workloads where relationships and traversals are the core query pattern. Use it for fraud rings, recommendations, or dependency graphs; compare with relational or document stores when connected-data traversal is not the main problem.",
            tags: ["Databases", "Graph", "Specialized"]
        ),
        SeedDecks.card(
            "aws-documentdb",
            deck: .awsServices,
            title: "Amazon DocumentDB",
            prompt: "What is DocumentDB, and when might it be useful?",
            answer: "DocumentDB is a managed document database positioned for MongoDB-style workloads. Use it when teams want flexible document storage under AWS management; compare carefully against self-managed MongoDB when exact feature compatibility matters.",
            tags: ["Databases", "Document", "Managed"]
        ),
        SeedDecks.card(
            "aws-timestream",
            deck: .awsServices,
            title: "Amazon Timestream",
            prompt: "Why would you choose Timestream over a general-purpose database?",
            answer: "Timestream is purpose-built for time-series data such as metrics, telemetry, and IoT events. Use it when timestamped writes and time-window queries dominate; compare with RDS or DynamoDB only when the workload is not primarily time-series shaped.",
            tags: ["Databases", "Time Series", "Telemetry"]
        ),

        // Networking and CDN
        SeedDecks.card(
            "aws-vpc",
            deck: .awsServices,
            title: "Amazon VPC",
            prompt: "What is a VPC, and why is it foundational in AWS?",
            answer: "A VPC is the network boundary around your AWS workloads: subnets, routes, gateways, and exposure decisions all live here. Good VPC design is foundational because poor network segmentation becomes a platform-wide problem very quickly.",
            tags: ["Networking", "Core AWS", "Security"]
        ),
        SeedDecks.card(
            "aws-route53",
            deck: .awsServices,
            title: "Amazon Route 53",
            prompt: "What role does Route 53 play beyond simple DNS hosting?",
            answer: "Route 53 is DNS plus routing controls such as failover, weighted traffic, and latency-based policies. Use it for global entry and regional failover; compare with Global Accelerator when you need faster failover and edge-network traffic steering beyond DNS behavior.",
            tags: ["Networking", "DNS", "Global"]
        ),
        SeedDecks.card(
            "aws-cloudfront",
            deck: .awsServices,
            title: "Amazon CloudFront",
            prompt: "What is CloudFront used for in modern architectures?",
            answer: "CloudFront is AWS's CDN for caching static and cache-friendly content close to users. Use it for web assets, downloads, or shielding origins; compare with Global Accelerator when the goal is transport optimization and failover rather than cache distribution.",
            tags: ["Networking", "CDN", "Edge"]
        ),
        SeedDecks.card(
            "aws-api-gateway",
            deck: .awsServices,
            title: "Amazon API Gateway",
            prompt: "When is API Gateway a good front door?",
            answer: "API Gateway is a managed front door for REST, HTTP, and WebSocket APIs with auth and throttling built in. It is strong for serverless and managed API patterns; compare with ALB when you want a simpler HTTP entry point for container or EC2 apps.",
            tags: ["Networking", "API", "Serverless"]
        ),
        SeedDecks.card(
            "aws-direct-connect",
            deck: .awsServices,
            title: "AWS Direct Connect",
            prompt: "What problem does Direct Connect solve?",
            answer: "Direct Connect gives you dedicated private connectivity between on-prem and AWS. Use it for stable, high-throughput hybrid traffic or regulated environments; compare with VPN when you need faster setup and can tolerate internet-based transport characteristics.",
            tags: ["Networking", "Hybrid", "Connectivity"]
        ),
        SeedDecks.card(
            "aws-transit-gateway",
            deck: .awsServices,
            title: "AWS Transit Gateway",
            prompt: "When does Transit Gateway become useful?",
            answer: "Transit Gateway centralizes connectivity across many VPCs and on-prem links so you do not manage a full mesh of peering relationships. Use it when network scale and account sprawl make point-to-point designs unmanageable.",
            tags: ["Networking", "Multi-VPC", "Hybrid"]
        ),
        SeedDecks.card(
            "aws-global-accelerator",
            deck: .awsServices,
            title: "AWS Global Accelerator",
            prompt: "What is Global Accelerator best at?",
            answer: "Global Accelerator improves global pathing to healthy regional endpoints over the AWS edge network. Use it for multi-region apps needing fast failover and steadier performance; compare with CloudFront when the main goal is content caching, not endpoint acceleration.",
            tags: ["Networking", "Global", "Traffic Routing"]
        ),
        SeedDecks.card(
            "aws-elb-alb-nlb",
            deck: .awsServices,
            title: "Elastic Load Balancing",
            prompt: "How do ALB and NLB differ, and when does ELB matter?",
            answer: "ALB is for HTTP/HTTPS with smart routing rules; NLB is for high-performance TCP/UDP with static IP characteristics. Choose based on protocol and routing needs, not habit, because the wrong load balancer either limits features or adds unnecessary complexity.",
            tags: ["Networking", "Load Balancing", "Traffic"]
        ),

        // Security and Identity
        SeedDecks.card(
            "aws-iam",
            deck: .awsServices,
            title: "AWS IAM",
            prompt: "Why is IAM central to almost every AWS design?",
            answer: "IAM is the permission system for users, roles, and service access across AWS. It is central because every architecture choice eventually becomes an access-control question; the most common failure mode is broad convenience permissions that quietly become systemic risk.",
            tags: ["Security", "Identity", "Core AWS"]
        ),
        SeedDecks.card(
            "aws-cognito",
            deck: .awsServices,
            title: "Amazon Cognito",
            prompt: "When is Cognito a reasonable identity choice?",
            answer: "Cognito is managed customer identity for sign-up, sign-in, and federation in apps. Use it when you want app-user auth without building an identity stack; compare with enterprise IdPs when the requirement is complex workforce identity or advanced access policy.",
            tags: ["Security", "Identity", "User Auth"]
        ),
        SeedDecks.card(
            "aws-kms",
            deck: .awsServices,
            title: "AWS KMS",
            prompt: "What does KMS provide in a cloud architecture?",
            answer: "KMS manages encryption keys and key usage policy across AWS services and applications. Use it when encrypted storage and auditable key control matter; the architectural caution is that weak key policy can undo the value of encryption very quickly.",
            tags: ["Security", "Encryption", "Keys"]
        ),
        SeedDecks.card(
            "aws-secrets-manager",
            deck: .awsServices,
            title: "AWS Secrets Manager",
            prompt: "Why use Secrets Manager instead of hard-coded config or plain Parameter Store?",
            answer: "Secrets Manager stores and rotates sensitive values such as passwords and API keys. Use it when secret lifecycle matters; compare with hard-coded or manually rotated secrets only if you are willing to accept operational and security debt.",
            tags: ["Security", "Secrets", "Operations"]
        ),
        SeedDecks.card(
            "aws-waf",
            deck: .awsServices,
            title: "AWS WAF",
            prompt: "What role does AWS WAF play in front of applications?",
            answer: "WAF filters web requests based on rules for common attacks, abuse patterns, and bots. Use it in front of CloudFront, ALB, or API Gateway; compare with Shield, which focuses on DDoS rather than HTTP-layer filtering.",
            tags: ["Security", "Web", "Protection"]
        ),
        SeedDecks.card(
            "aws-shield",
            deck: .awsServices,
            title: "AWS Shield",
            prompt: "What is Shield for, and how does it relate to WAF?",
            answer: "Shield is DDoS protection for internet-facing AWS resources. Use it for volumetric and network-layer protection; pair it with WAF when you also need application-layer request filtering.",
            tags: ["Security", "DDoS", "Protection"]
        ),
        SeedDecks.card(
            "aws-guardduty",
            deck: .awsServices,
            title: "Amazon GuardDuty",
            prompt: "What does GuardDuty detect?",
            answer: "GuardDuty analyzes AWS telemetry for signs of compromise or suspicious behavior. Use it for managed threat detection at the account and workload level; compare with Security Hub, which aggregates findings, not detects them itself.",
            tags: ["Security", "Threat Detection", "Monitoring"]
        ),
        SeedDecks.card(
            "aws-inspector",
            deck: .awsServices,
            title: "Amazon Inspector",
            prompt: "When should Inspector be part of the architecture?",
            answer: "Inspector scans compute workloads for vulnerabilities and unintended exposure. Use it when you need continuous workload assessment; compare with GuardDuty, which looks for active threat signals rather than package and configuration weaknesses.",
            tags: ["Security", "Vulnerability", "Assessment"]
        ),
        SeedDecks.card(
            "aws-macie",
            deck: .awsServices,
            title: "Amazon Macie",
            prompt: "What problem is Macie trying to solve?",
            answer: "Macie discovers and classifies sensitive data, especially in S3. Use it when you need visibility into where regulated or confidential content lives; compare with IAM or bucket policies, which control access but do not tell you what data is actually there.",
            tags: ["Security", "Data Protection", "Compliance"]
        ),
        SeedDecks.card(
            "aws-security-hub",
            deck: .awsServices,
            title: "AWS Security Hub",
            prompt: "What does Security Hub add to a security architecture?",
            answer: "Security Hub consolidates security findings and standards views across AWS and partner tools. Use it when security operations need one place to prioritize action; compare with GuardDuty or Inspector, which generate findings rather than aggregate them.",
            tags: ["Security", "Operations", "Visibility"]
        ),

        // Integration and Messaging
        SeedDecks.card(
            "aws-sqs",
            deck: .awsServices,
            title: "Amazon SQS",
            prompt: "What is SQS best for in distributed systems?",
            answer: "SQS is a durable queue for decoupling producers from consumers and absorbing traffic spikes. Use it for background jobs and async processing; compare with SNS when the same message needs fan-out to many consumers rather than one worker pool.",
            tags: ["Integration", "Queue", "Async"]
        ),
        SeedDecks.card(
            "aws-sns",
            deck: .awsServices,
            title: "Amazon SNS",
            prompt: "When is SNS the better messaging choice?",
            answer: "SNS is pub/sub for broadcasting one event to many subscribers. Use it when multiple systems need the same notification; compare with SQS when you need durable single-consumer work semantics instead of fan-out.",
            tags: ["Integration", "PubSub", "Notifications"]
        ),
        SeedDecks.card(
            "aws-eventbridge",
            deck: .awsServices,
            title: "Amazon EventBridge",
            prompt: "What is EventBridge for, and how is it different from simple pub/sub?",
            answer: "EventBridge is an event bus with routing rules, filtering, and SaaS/AWS integration patterns. Use it for event-driven integration across many producers and consumers; compare with SNS when simple broadcast is enough and you do not need rule-based routing.",
            tags: ["Integration", "Events", "Routing"]
        ),
        SeedDecks.card(
            "aws-step-functions",
            deck: .awsServices,
            title: "AWS Step Functions",
            prompt: "When do Step Functions improve a design?",
            answer: "Step Functions orchestrates multi-step workflows with retries, waits, and visible state. Use it when the business process spans several services and you want execution tracking; compare with EventBridge or SQS when loose choreography is enough and central orchestration is unnecessary.",
            tags: ["Integration", "Workflow", "Orchestration"]
        ),
        SeedDecks.card(
            "aws-mq",
            deck: .awsServices,
            title: "Amazon MQ",
            prompt: "Why would a team use Amazon MQ instead of native AWS messaging services?",
            answer: "Amazon MQ is managed broker infrastructure for protocols and semantics teams already depend on, such as ActiveMQ or RabbitMQ. Use it mainly for compatibility or migration; compare with SQS/SNS/EventBridge for greenfield AWS-native designs.",
            tags: ["Integration", "Messaging", "Migration"]
        ),
        SeedDecks.card(
            "aws-kinesis",
            deck: .awsServices,
            title: "Amazon Kinesis",
            prompt: "What kinds of workloads fit Kinesis?",
            answer: "Kinesis is for high-throughput streaming events such as clickstreams, telemetry, and log pipelines. Use it when ordering and continuous ingestion matter; compare with SQS when the workload is discrete task processing rather than stream processing.",
            tags: ["Integration", "Streaming", "Real Time"]
        ),

        // Observability and Operations
        SeedDecks.card(
            "aws-cloudwatch",
            deck: .awsServices,
            title: "Amazon CloudWatch",
            prompt: "What does CloudWatch cover in day-to-day operations?",
            answer: "CloudWatch is the default AWS layer for metrics, logs, alarms, and dashboards. Use it for core service observability; compare with specialized third-party tools when you need deeper analytics, cross-platform correlation, or richer query ergonomics.",
            tags: ["Operations", "Monitoring", "Observability"]
        ),
        SeedDecks.card(
            "aws-cloudtrail",
            deck: .awsServices,
            title: "AWS CloudTrail",
            prompt: "What is CloudTrail for?",
            answer: "CloudTrail records API activity and control-plane actions across AWS accounts. Use it for audit, investigations, and change tracking; compare with CloudWatch Logs, which focus on application or service runtime events, not account-level API history.",
            tags: ["Operations", "Audit", "Security"]
        ),
        SeedDecks.card(
            "aws-xray",
            deck: .awsServices,
            title: "AWS X-Ray",
            prompt: "When does X-Ray add real value?",
            answer: "X-Ray adds distributed tracing so you can follow one request across services and see where time or errors accumulated. Use it when latency attribution matters; compare with CloudWatch metrics when you only need aggregate health, not per-request path detail.",
            tags: ["Operations", "Tracing", "Latency"]
        ),
        SeedDecks.card(
            "aws-systems-manager",
            deck: .awsServices,
            title: "AWS Systems Manager",
            prompt: "Why is Systems Manager useful operationally?",
            answer: "Systems Manager is AWS operational glue for patching, run commands, automation, inventory, and parameter handling. Use it to reduce manual fleet operations; compare with bespoke scripts when scale, auditability, and consistency start to matter.",
            tags: ["Operations", "Automation", "Management"]
        ),
        SeedDecks.card(
            "aws-config",
            deck: .awsServices,
            title: "AWS Config",
            prompt: "What problem does AWS Config solve?",
            answer: "Config records resource configuration history and evaluates rules for compliance or drift. Use it when governance needs proof and change visibility; compare with CloudTrail, which tells you who changed something, while Config shows the resulting configuration state.",
            tags: ["Operations", "Governance", "Compliance"]
        ),
        SeedDecks.card(
            "aws-trusted-advisor",
            deck: .awsServices,
            title: "AWS Trusted Advisor",
            prompt: "What is Trusted Advisor good at?",
            answer: "Trusted Advisor gives AWS best-practice checks around cost, limits, resilience, and some security issues. Use it as a hygiene review surface; compare with hands-on architecture review because it points out common issues, not solution-specific tradeoffs.",
            tags: ["Operations", "Optimization", "Governance"]
        ),

        // Dev Tools and IaC
        SeedDecks.card(
            "aws-codepipeline",
            deck: .awsServices,
            title: "AWS CodePipeline",
            prompt: "What role does CodePipeline play in delivery?",
            answer: "CodePipeline orchestrates stages across build, test, approval, and deploy in an AWS-native CI/CD flow. Use it when you want managed pipeline control in AWS; compare with GitHub Actions or other CI/CD tools when broader ecosystem fit matters more.",
            tags: ["DevTools", "CI/CD", "Delivery"]
        ),
        SeedDecks.card(
            "aws-codebuild",
            deck: .awsServices,
            title: "AWS CodeBuild",
            prompt: "What is CodeBuild best suited for?",
            answer: "CodeBuild is managed build infrastructure for compiling code, running tests, and producing artifacts. Use it when you want elastic builds without managing runners; compare with self-hosted runners if you need deep customization or local-network build dependencies.",
            tags: ["DevTools", "CI", "Build"]
        ),
        SeedDecks.card(
            "aws-codedeploy",
            deck: .awsServices,
            title: "AWS CodeDeploy",
            prompt: "When does CodeDeploy matter?",
            answer: "CodeDeploy automates rollouts across EC2, Lambda, and ECS with strategies such as blue-green and rolling. Use it when deployment control and rollback behavior matter; compare with simpler push-based deploys when release risk is low and topology is small.",
            tags: ["DevTools", "Deploy", "Release"]
        ),
        SeedDecks.card(
            "aws-cloudformation",
            deck: .awsServices,
            title: "AWS CloudFormation",
            prompt: "Why is CloudFormation important in AWS architecture?",
            answer: "CloudFormation is declarative infrastructure as code for reproducible AWS environments. Use it when environment consistency, reviewability, and repeatability matter; compare with console-driven setup, which is faster once and painful every time after.",
            tags: ["DevTools", "IaC", "Provisioning"]
        ),
        SeedDecks.card(
            "aws-cdk",
            deck: .awsServices,
            title: "AWS CDK",
            prompt: "What does CDK change compared with raw CloudFormation?",
            answer: "CDK lets you define infrastructure in code and synthesize it to CloudFormation. Use it when reusable constructs and developer ergonomics matter; compare with raw templates when you want maximum transparency and minimal abstraction.",
            tags: ["DevTools", "IaC", "Developer Experience"]
        ),

        // Data, Analytics, and ML
        SeedDecks.card(
            "aws-glue",
            deck: .awsServices,
            title: "AWS Glue",
            prompt: "What is Glue for in data architectures?",
            answer: "Glue is managed data integration for cataloging, ETL, and pipeline jobs. Use it when teams need AWS-managed transformation workflows; compare with EMR or Spark platforms when you need deeper control than managed ETL provides.",
            tags: ["Data", "ETL", "Analytics"]
        ),
        SeedDecks.card(
            "aws-athena",
            deck: .awsServices,
            title: "Amazon Athena",
            prompt: "When is Athena the right query tool?",
            answer: "Athena is serverless SQL over data in S3. Use it for ad hoc analytics and lightweight reporting without standing up a warehouse; compare with Redshift when performance, concurrency, and modeled analytics justify a dedicated platform.",
            tags: ["Data", "Query", "Serverless Analytics"]
        ),
        SeedDecks.card(
            "aws-emr",
            deck: .awsServices,
            title: "Amazon EMR",
            prompt: "What workloads justify EMR?",
            answer: "EMR is managed big-data cluster infrastructure for Spark, Hadoop, and similar frameworks. Use it when large-scale distributed processing needs more control than serverless analytics tools provide; compare with Glue for lighter managed ETL cases.",
            tags: ["Data", "Big Data", "Processing"]
        ),
        SeedDecks.card(
            "aws-opensearch",
            deck: .awsServices,
            title: "Amazon OpenSearch Service",
            prompt: "When is OpenSearch the right service choice?",
            answer: "OpenSearch is for full-text search, faceting, and log analytics. Use it when retrieval speed over text or operational event data matters; compare with RDS or DynamoDB when the workload is transactional rather than search-oriented.",
            tags: ["Data", "Search", "Analytics"]
        ),
        SeedDecks.card(
            "aws-quicksight",
            deck: .awsServices,
            title: "Amazon QuickSight",
            prompt: "What is QuickSight built for?",
            answer: "QuickSight is managed BI and dashboarding for business-facing reporting. Use it when you want dashboards over governed datasets without building custom UI; compare with bespoke analytics apps when embedding, workflow integration, or custom interactivity dominates.",
            tags: ["Data", "BI", "Dashboards"]
        ),
        SeedDecks.card(
            "aws-sagemaker",
            deck: .awsServices,
            title: "Amazon SageMaker",
            prompt: "When should SageMaker be part of the solution?",
            answer: "SageMaker is a managed ML platform for training, deploying, and operating models. Use it when the team truly has an ML lifecycle to support; compare with simpler hosted inference or external ML platforms when the use case is narrow or the team is not ML-mature.",
            tags: ["ML", "Data", "Model Platform"]
        ),

        // Migration and Hybrid
        SeedDecks.card(
            "aws-dms",
            deck: .awsServices,
            title: "AWS Database Migration Service",
            prompt: "What is DMS best used for?",
            answer: "DMS moves data between databases and can keep replication going during migration cutovers. Use it to reduce database migration downtime; compare with full replatform efforts where schema and application changes matter as much as raw data movement.",
            tags: ["Migration", "Databases", "Hybrid"]
        ),
        SeedDecks.card(
            "aws-snow-family",
            deck: .awsServices,
            title: "AWS Snow Family",
            prompt: "When do Snow devices make sense?",
            answer: "Snow devices move or process large datasets physically when network transfer is too slow or unreliable. Use them for edge sites or huge migrations; compare with DataSync or online transfer when connectivity is strong enough to stay purely network-based.",
            tags: ["Migration", "Edge", "Data Transfer"]
        ),
        SeedDecks.card(
            "aws-storage-gateway",
            deck: .awsServices,
            title: "AWS Storage Gateway",
            prompt: "What does Storage Gateway solve in hybrid setups?",
            answer: "Storage Gateway exposes AWS storage through familiar on-prem file, volume, or tape interfaces. Use it to bridge legacy environments into AWS-backed storage patterns; compare with DataSync when the need is transfer, not ongoing hybrid access semantics.",
            tags: ["Migration", "Hybrid", "Storage"]
        ),
        SeedDecks.card(
            "aws-datasync",
            deck: .awsServices,
            title: "AWS DataSync",
            prompt: "What is DataSync for?",
            answer: "DataSync is managed online transfer between on-prem storage and AWS targets such as S3, EFS, or FSx. Use it for large migrations or recurring sync; compare with Snow devices when bandwidth makes network transfer impractical.",
            tags: ["Migration", "Data Transfer", "Hybrid"]
        ),

        // Edge and Other Important Services
        SeedDecks.card(
            "aws-organizations",
            deck: .awsServices,
            title: "AWS Organizations",
            prompt: "Why is Organizations important in multi-account AWS design?",
            answer: "Organizations is the control plane for multi-account structure, billing, and policy at enterprise scale. Use it when account separation is part of your security and operating model; compare with single-account designs, which usually stop scaling operationally before they stop scaling technically.",
            tags: ["Governance", "Multi-Account", "Core AWS"]
        ),
        SeedDecks.card(
            "aws-control-tower",
            deck: .awsServices,
            title: "AWS Control Tower",
            prompt: "What does Control Tower add on top of Organizations?",
            answer: "Control Tower adds a managed landing-zone setup with guardrails and account patterns on top of Organizations. Use it to accelerate enterprise AWS foundations; compare with building your own landing zone when you need deeper customization than the managed pattern allows.",
            tags: ["Governance", "Landing Zone", "Multi-Account"]
        ),
        SeedDecks.card(
            "aws-backup",
            deck: .awsServices,
            title: "AWS Backup",
            prompt: "What is AWS Backup useful for?",
            answer: "AWS Backup centralizes backup policy and retention across supported services. Use it when governance wants consistency across accounts and workloads; compare with service-by-service backups if you are willing to trade central control for local variation and drift.",
            tags: ["Operations", "Backup", "Recovery"]
        ),
        SeedDecks.card(
            "aws-ses",
            deck: .awsServices,
            title: "Amazon SES",
            prompt: "When is SES the right service to use?",
            answer: "SES is managed outbound email for transactional and bulk messaging. Use it for receipts, notifications, or password resets; compare with third-party email platforms when analytics, templates, or marketing workflows are the dominant requirement.",
            tags: ["Communication", "Email", "Applications"]
        ),
        SeedDecks.card(
            "aws-workspaces",
            deck: .awsServices,
            title: "Amazon WorkSpaces",
            prompt: "What problem does WorkSpaces solve?",
            answer: "WorkSpaces is managed virtual desktop infrastructure in AWS. Use it for secure remote desktops, contractors, or temporary workforce environments; compare with app modernization when the business actually needs application redesign rather than hosted desktops.",
            tags: ["End User", "Virtual Desktop", "Managed"]
        )
    ]
}
