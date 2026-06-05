# Pod Security Context Reference

Canonical reference for Kubernetes pod and container security contexts. Referenced by multiple skills.

## Pod Security Context (spec.securityContext)

```yaml
spec:
  securityContext:
    # Run all containers as non-root
    runAsNonRoot: true

    # Specific user/group IDs
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000

    # Supplemental groups for volume access
    supplementalGroups: [1000]

    # Seccomp profile (required for PSS restricted)
    seccompProfile:
      type: RuntimeDefault  # or Localhost with localhostProfile

    # Sysctls (use with caution)
    sysctls:
      - name: net.core.somaxconn
        value: "1024"
```

## Container Security Context (spec.containers[].securityContext)

```yaml
spec:
  containers:
  - name: app
    securityContext:
      # Prevent privilege escalation via setuid/setgid
      allowPrivilegeEscalation: false

      # Immutable root filesystem
      readOnlyRootFilesystem: true

      # Non-root user (redundant with pod-level but explicit)
      runAsNonRoot: true
      runAsUser: 1000
      runAsGroup: 1000

      # Drop all capabilities
      capabilities:
        drop:
          - ALL
        # Add only what's needed (rare)
        # add:
        #   - NET_BIND_SERVICE

      # Seccomp at container level
      seccompProfile:
        type: RuntimeDefault

      # SELinux options (if using SELinux)
      # seLinuxOptions:
      #   level: "s0:c123,c456"
```

## Pod Security Standards Profiles

| Profile | Use Case | Key Requirements |
|---------|----------|------------------|
| **Privileged** | System/infra pods | No restrictions |
| **Baseline** | General workloads | No privileged, no hostPath, no host namespaces |
| **Restricted** | Security-sensitive | Non-root, drop all caps, read-only root, seccomp |

## Restricted Profile Requirements

```yaml
# All of these are REQUIRED for PSS restricted:
spec:
  securityContext:
    runAsNonRoot: true
    seccompProfile:
      type: RuntimeDefault
  containers:
  - securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop: [ALL]
```

## Quick Reference Table

| Setting | Pod Level | Container Level | Restricted Required |
|---------|-----------|-----------------|---------------------|
| runAsNonRoot | ✓ | ✓ | Yes |
| runAsUser | ✓ | ✓ | No (but recommended) |
| runAsGroup | ✓ | ✓ | No |
| fsGroup | ✓ | - | No |
| allowPrivilegeEscalation | - | ✓ | Yes (must be false) |
| readOnlyRootFilesystem | - | ✓ | No (but recommended) |
| capabilities | - | ✓ | Yes (drop ALL) |
| seccompProfile | ✓ | ✓ | Yes (RuntimeDefault) |
| privileged | - | ✓ | Yes (must be false/absent) |

## Anti-Patterns

```yaml
# ❌ NEVER in production
securityContext:
  privileged: true           # Full host access
  runAsUser: 0               # Root user
  allowPrivilegeEscalation: true  # Default, should be false

# ❌ Dangerous host access
hostNetwork: true
hostPID: true
hostIPC: true
volumes:
  - hostPath:
      path: /
```

## Namespace Enforcement

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: secure-namespace
  labels:
    # Enforce restricted profile
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/enforce-version: latest
    # Audit and warn for violations
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```
