# Docker Bind Mounts Consistency Options

Docker bind mounts allow you to mount a host file or directory into a container, enabling data sharing between the host and the container. When using bind mounts on systems like macOS or Windows, where Docker runs in a virtualized environment, you can specify consistency options (`consistent`, `cached`, or `delegated`) to control how data synchronization behaves between the host and container. These options are particularly relevant for Docker Desktop, as they address performance and consistency trade-offs due to the virtualization layer.

## Consistency Options

1. **default (Equivalent to `consistent`)**
   - **Definition**: Ensures the container runtime and the host maintain an identical view of the mounted data at all times.
   - **Behavior**: Changes on the host are immediately reflected in the container, and vice versa, with no delay in synchronization.
   - **Use Case**: Ideal for scenarios requiring data integrity and real-time updates, such as databases or critical configuration files.
   - **Performance**: Slower due to strict synchronization, especially in virtualized environments like Docker Desktop on macOS/Windows.
   - **Drawbacks**: Performance overhead for frequent read/write operations.

2. **consistent**
   - **Definition**: Full consistency, where the host and container always have an identical view of the mount.
   - **Behavior**: Identical to `default`. Changes on either side are instantly synchronized.
   - **Use Case**: Suitable for applications where data consistency is critical, such as shared configuration files or databases.
   - **Performance**: Similar to `default`, may introduce latency due to immediate synchronization requirements.
   - **Drawbacks**: Reduced performance for high-frequency I/O operations.

3. **cached** (Most recommended for development)
   - **Definition**: The host's view of the mount is authoritative, with the container's read operations optimized.
   - **Behavior**: Host writes may have slight delay before appearing in container. Container reads are highly optimized.
   - **Use Case**: Best for development workflows where you edit code on the host and run applications in the container. Ideal for read-heavy workloads.
   - **Performance**: Can provide 10x+ performance improvement on macOS/Windows for file-heavy operations.
   - **Drawbacks**: Temporary inconsistencies may occur if the host modifies files while the container accesses them.

4. **delegated**
   - **Definition**: The container runtime's view is authoritative, with the container's write operations optimized.
   - **Behavior**: Container writes may have delay before appearing on host. Host changes are immediately visible in the container.
   - **Use Case**: Ideal for container-generated content like logs, build artifacts, and heavy write operations.
   - **Performance**: Faster for writes by allowing the container to operate independently without immediate host synchronization.
   - **Drawbacks**: Temporary inconsistencies may occur if the host accesses files before container changes are synchronized.

## Comparison

| **Option**     | **Consistency**                     | **Performance**                     | **Host-to-Container Sync** | **Container-to-Host Sync** | **Best Use Case**                     |
|----------------|-------------------------------------|-------------------------------------|----------------------------|----------------------------|---------------------------------------|
| **default**    | Full (same as `consistent`)         | Slower due to strict sync           | Immediate                  | Immediate                  | Real-time consistency needs           |
| **consistent** | Full (host/container in sync)       | Slower due to strict sync           | Immediate                  | Immediate                  | Databases, shared configs             |
| **cached**     | Host authoritative, possible delays | **10x+ faster for reads**           | Delayed                    | Immediate                  | Development, read-heavy workloads     |
| **delegated**  | Container authoritative, delays     | **Faster for writes**               | Immediate                  | Delayed                    | Container logs, build artifacts       |

## Key Considerations

- **Performance vs. Consistency**:
  - `consistent` prioritizes data integrity, suitable for critical applications but slower.
  - `cached` optimizes for read performance, ideal for development workflows (most recommended).
  - `delegated` optimizes for write performance, suitable for container-driven workflows.

- **Platform Relevance**:
  - **macOS/Windows**: These options provide significant performance improvements due to virtualization layer.
  - **Linux**: All consistency flags are **ignored** - native bind mounts are already optimal.

- **Choosing the Right Option**:
  - **Start with `cached`** for most development scenarios
  - Use `consistent` for applications sensitive to data mismatches
  - Use `delegated` for container-generated content (logs, builds, caches)
  - If unspecified, `default` (equivalent to `consistent`) is used

## Docker Compose Syntax Examples

### Short Syntax
```yaml
version: '3.8'
services:
  web:
    image: nginx:latest
    volumes:
      # Format: [HOST_PATH]:[CONTAINER_PATH]:[OPTIONS]
      - ./src:/app:cached                    # Best for development
      - ./logs:/var/log/app:delegated        # Best for container writes
      - ./config:/etc/config:consistent      # Strict consistency
```

### Long Syntax (Recommended)
```yaml
version: '3.8'
services:
  app:
    image: node:latest
    volumes:
      - type: bind
        source: ./src
        target: /app
        consistency: cached
      - type: bind
        source: ./logs
        target: /app/logs
        consistency: delegated
```

### Complete Development Example
```yaml
version: '3.8'
services:
  development:
    image: php:fpm
    volumes:
      # Source code - optimize for host edits, container reads
      - ./src:/var/www/html:cached

      # Application logs - optimize for container writes
      - ./logs:/var/log/app:delegated

      # Configuration - require strict consistency
      - ./config/app.conf:/etc/app/app.conf:consistent

      # Node modules - optimize for container operations
      - node_modules:/app/node_modules:delegated
```

## Docker CLI Example

To specify a consistency option for a bind mount in a Docker service, use the `consistency` flag with the `--mount` option:

```bash
docker service create \
  --name my-service \
  --mount type=bind,source=/host/path,destination=/container/path,consistency=cached \
  nginx:alpine
```

## Docker Run Examples

```bash
# Using --mount (recommended)
docker run --mount type=bind,source="$(pwd)",target=/app,consistency=cached node:latest

# Using -v (short form)
docker run -v "$(pwd)":/app:cached node:latest
```

## References and Documentation Links

- [Docker Service Create - Options for Bind Mounts](https://docs.docker.com/reference/cli/docker/service/create/#options-for-bind-mounts)
- [Docker Bind Mounts Documentation](https://docs.docker.com/engine/storage/bind-mounts/)
- [Docker Compose Volumes Reference](https://docs.docker.com/reference/compose-file/volumes/)
- [Stack Overflow: Docker Compose Consistency Options](https://stackoverflow.com/questions/43844639/how-do-i-add-cached-or-delegated-into-a-docker-compose-yml-volumes-list)
- [GitHub Issue: Compose Consistency Support](https://github.com/docker/compose/issues/5388)
- [Docker Forums: Consistency Flags Discussion](https://forums.docker.com/t/what-happened-to-delegated-cached-ro-and-other-flags/105097)

## Current Status (2024)

While these consistency options may not be prominently featured in current Docker documentation, they remain **functional and effective** for Docker Desktop users on macOS and Windows who experience performance issues with bind mounts. The options are particularly valuable for development workflows where significant performance improvements can be achieved.