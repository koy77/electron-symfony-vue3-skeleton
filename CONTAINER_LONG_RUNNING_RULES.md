# Container Build Rules for Long-Running Processes

## Rule: Always Configure Long-Running Processes
When building containers that run long-running processes, follow these guidelines:

### 1. Use Proper Signal Handling
- Ensure your main process handles SIGTERM and SIGINT signals
- Implement graceful shutdown procedures
- Use `exec` to run the main process (PID 1)

### 2. Configure Health Checks
```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

### 3. Set Appropriate Timeouts
- Use `--timeout` parameter in bash tool for operations > 2 minutes
- Maximum timeout: 600000ms (10 minutes)
- Example: `bash(command="long-process", timeout=300000)`

### 4. Resource Management
- Set memory and CPU limits
- Configure restart policies
- Use proper logging drivers

### 5. Process Management
- Use process managers like supervisord for multiple processes
- Ensure proper PID 1 handling
- Implement wait strategies for dependencies

### 6. Environment Configuration
- Set appropriate environment variables
- Configure production-ready settings
- Use non-root users when possible

## Implementation Checklist
- [ ] Signal handling implemented
- [ ] Health checks configured
- [ ] Resource limits set
- [ ] Proper logging configured
- [ ] Security best practices followed
- [ ] Monitoring endpoints exposed