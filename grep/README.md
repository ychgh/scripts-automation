# grep task: monitor logs for errors

## Goal
Print matching error lines from one or more log files.

## Implementation
- Script: [`monitor-errors.sh`](./monitor-errors.sh)

## Usage
```bash
./monitor-errors.sh -p "ERROR|FATAL" /var/log/myapp/*.log
```
